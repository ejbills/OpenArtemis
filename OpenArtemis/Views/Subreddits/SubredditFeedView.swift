//
//  SubredditFeedView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/1/23.
//

import SwiftUI
import Defaults

struct SubredditFeedView: View {
    // MARK: - Properties
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var coordinator: NavCoordinator
    @EnvironmentObject var trackingParamRemover: TrackingParamRemover
    @Default(.over18) var over18
    
    let subredditName: String
    let titleOverride: String?
    let appTheme: AppThemeSettings
    
    @State private var posts: [Post] = []
    @State private var postIDs = LimitedSet<String>(maxLength: 300)
    @State private var lastPostAfter: String = ""
    @State private var sortOption: SortOption = .best
    @State private var isLoading: Bool = false
    
    @State private var searchTerm: String = ""
    @State private var searchResults: [MixedMedia] = []
    @State private var mixedMediaIDs = LimitedSet<String>(maxLength: 300)
    @State private var selectedSearchSortOption: PostSortOption = .relevance
    @State private var selectedSearchTopOption: TopPostListingSortOption = .all
    
    @FetchRequest(
        entity: SavedPost.entity(),
        sortDescriptors: []
    ) var savedPosts: FetchedResults<SavedPost>
    
    @FetchRequest(
        entity: ReadPost.entity(),
        sortDescriptors: []
    ) var readPosts: FetchedResults<ReadPost>
    
    
    // MARK: - Body
    var body: some View {
        Group {
            ThemedList(appTheme: appTheme, stripStyling: true) {
                if !posts.isEmpty && searchTerm.isEmpty {
                    ForEach(posts, id: \.id) { post in
                        var isRead: Bool {
                            readPosts.contains(where: { $0.readPostId == post.id })
                        }
                        var isSaved: Bool {
                            savedPosts.contains { $0.id == post.id }
                        }
                        
                        PostFeedView(post: post, isRead: isRead, appTheme: appTheme)
                            .savedIndicator(isSaved)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                coordinator.path.append(PostResponse(post: post))
                                
                                if !isRead {
                                    PostUtils.shared.toggleRead(context: managedObjectContext, postId: post.id)
                                }
                            }
                        
                        DividerView(frameHeight: 10, appTheme: appTheme)
                    }
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 1)
                        .onAppear {
                            scrapeSubreddit(lastPostAfter)
                        }
                    
                    if isLoading { // show spinner at the bottom of the feed
                        HStack {
                            Spacer()
                            ProgressView()
                                .id(UUID()) // swift ui bug, needs a uuid to render multiple times. :|
                                .padding()
                            Spacer()
                        }
                    }
                } else if !searchResults.isEmpty || !searchTerm.isEmpty {
                    FilterView(selectedSortOption: $selectedSearchSortOption, selectedTopOption: $selectedSearchTopOption) {
                        clearFeedAndReload(withSearchTerm: "subreddit:\(subredditName) \(searchTerm)")
                    }
                    ContentListView(content: $searchResults, readPosts: readPosts, savedPosts: savedPosts, appTheme: appTheme)
                } else {
                    LoadingView(loadingText: "Loading feed...", isLoading: isLoading)
                }
            }
        }
        .navigationTitle((titleOverride != nil) ? titleOverride! : subredditName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            buildSortingMenu()
        }
        .onAppear {
            if posts.isEmpty {
                scrapeSubreddit()
            }
        }
        .refreshable {
            clearFeedAndReload()
        }
        .onChange(of: subredditName) { _, _ in // this handles a navsplitview edge case where swiftui reuses the initial view from the sidebar selection.
            clearFeedAndReload()
        }
        .searchable(text: $searchTerm, prompt: "Search r/\((titleOverride != nil) ? titleOverride! : subredditName)")
        .onSubmit(of: .search) {
            clearFeedAndReload(withSearchTerm: "subreddit:\(subredditName) \(searchTerm)")
        }
        .onChange(of: searchTerm) { val, _ in if searchTerm.isEmpty { clearFeedAndReload() }}
    }
    
    // MARK: - Private Methods
    
    private func handlePostAppearance(_ postId: String) {
        if !posts.isEmpty && posts.count > Int(Double(posts.count) * 0.85) {
            if postId == posts[Int(Double(posts.count) * 0.85)].id {
                scrapeSubreddit(lastPostAfter, sort: sortOption)
            }
        }
    }
    
    private func buildSortingMenu() -> some View {
        Menu(content: {
            ForEach(SortOption.allCases) { opt in
                if case .top(_) = opt {
                    Menu {
                        ForEach(SortOption.TopListingSortOption.allCases, id: \.self) { topOpt in
                            Button {
                                sortOption = .top(topOpt)
                                clearFeedAndReload()
                            } label: {
                                HStack {
                                    Text(topOpt.rawValue.capitalized)
                                    Spacer()
                                    Image(systemName: topOpt.icon)
                                        .foregroundColor(Color.artemisAccent)
                                        .font(.system(size: 17, weight: .bold))
                                }
                            }
                        }
                    } label: {
                        Label(opt.rawVal.value.capitalized, systemImage: opt.rawVal.icon)
                            .foregroundColor(Color.artemisAccent)
                            .font(.system(size: 17, weight: .bold))
                    }
                } else {
                    Button {
                        sortOption = opt
                        clearFeedAndReload()
                    } label: {
                        HStack {
                            Text(opt.rawVal.value.capitalized)
                            Spacer()
                            Image(systemName: opt.rawVal.icon)
                                .foregroundColor(Color.artemisAccent)
                                .font(.system(size: 17, weight: .bold))
                        }
                    }
                }
            }
        }, label: {
            Image(systemName: sortOption.rawVal.icon)
                .foregroundColor(Color.artemisAccent)
        })
    }
    
    private func scrapeSubreddit(_ lastPostAfter: String? = nil, sort: SortOption? = nil, searchTerm: String = "") {
        self.isLoading = true
        
        if searchTerm.isEmpty {
            RedditScraper.scrapeSubreddit(subreddit: subredditName, lastPostAfter: lastPostAfter, sort: sort,
                                          trackingParamRemover: trackingParamRemover, over18: over18) { result in
                defer {
                    isLoading = false
                }
                
                switch result {
                case .success(let newPosts):
                    for post in newPosts {
                        if !postIDs.contains(post.id) {
                            posts.append(post)
                            postIDs.insert(post.id)
                        }
                    }
                    
                    if let lastPost = newPosts.last {
                        self.lastPostAfter = lastPost.id
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        } else {
            RedditScraper.search(query: searchTerm, searchType: "", sortBy: selectedSearchSortOption, topSortBy: selectedSearchTopOption,
                                 trackingParamRemover: trackingParamRemover, over18: over18) { result in
                defer {
                    isLoading = false
                }
                
                switch result {
                case .success(let newMedia):
                    for media in newMedia {
                        let mediaID = MiscUtils.extractMediaId(from: media)
                        if !mixedMediaIDs.contains(mediaID) {
                            searchResults.append(media)
                            mixedMediaIDs.insert(mediaID)
                        }
                    }
                case .failure(let error):
                    print("Search error: \(error)")
                }
            }
        }
    }
    
    private func clearFeedAndReload(withSearchTerm: String = "") {
        withAnimation(.smooth) {
            posts.removeAll()
            postIDs.removeAll()
            searchResults.removeAll()
            mixedMediaIDs.removeAll()
            lastPostAfter = ""
            isLoading = false
        }
        
        scrapeSubreddit(sort: sortOption, searchTerm: withSearchTerm)
    }
}
