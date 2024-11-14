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
    @Default(.hideReadPosts) var hideReadPosts
    @Default(.markReadOnScroll) var markReadOnScroll

    let subredditName: String
    let titleOverride: String?
    let appTheme: AppThemeSettings
    let textSizePreference: TextSizePreference
    
    @State private var forceCompactMode: Bool = false
    
    @State private var posts: [Post] = []
    @State private var postIDs = LimitedSet<String>(maxLength: 300)
    @State private var lastPostAfter: String = ""
    @State private var retryCount: Int = 0
    @State private var sortOption: SortOption = Defaults[.defaultSubSorting]
    @State private var isLoading: Bool = false
    
    @State private var searchTerm: String = ""
    @State private var searchResults: [MixedMedia] = []
    @State private var mixedMediaIDs = LimitedSet<String>(maxLength: 300)
    @State private var selectedSearchSortOption: PostSortOption = .relevance
    @State private var selectedSearchTopOption: TopPostListingSortOption = .all
    
    @State private var listIdentifier = "" // this handles generating a new identifier on load to prevent stale data
    
    @FetchRequest(
        entity: SavedPost.entity(),
        sortDescriptors: []
    ) var savedPosts: FetchedResults<SavedPost>
    
    @FetchRequest(
        entity: ReadPost.entity(),
        sortDescriptors: []
    ) var readPosts: FetchedResults<ReadPost>
    
    // Tracks posts that were just read due to scrolling, so we don't remove them until we reload
    // This helps prevent the list from jumping around
    @State private var justReadDueToScrollingPostIds: Set<String> = []

    // MARK: - Body
    var body: some View {
        Group {
            ThemedList(appTheme: appTheme, textSizePreference: textSizePreference, stripStyling: true) {
                if !posts.isEmpty && searchTerm.isEmpty {
                    ForEach(posts, id: \.id) { post in
                        var isRead: Bool {
                            readPosts.contains(where: { $0.readPostId == post.id })
                        }
                        let justRead = justReadDueToScrollingPostIds.contains(post.id)
                        
                        var isSaved: Bool {
                            savedPosts.contains { $0.id == post.id }
                        }
                        
                        if !hideReadPosts || (!isRead || isSaved || (isRead && justRead)) {
                            PostFeedItemView(post: post, isRead: isRead, forceCompactMode: forceCompactMode, isSaved: isSaved, appTheme: appTheme, textSizePreference: textSizePreference) {
                                handlePostTap(post, isRead: isRead)
                            }
                            .if(markReadOnScroll, transform: { postFeedItem in
                                postFeedItem.onScrolledOffTopOfScreen {
                                    PostUtils.shared.toggleRead(context: managedObjectContext, postId: post.id)
                                    justReadDueToScrollingPostIds.insert(post.id)
                                }
                            })
                        }
                    }
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 1)
                        .id(UUID()) // adding this causes onAppear to be called multiple times even if the view didn't leave the screen
                        .onAppear {
                            scrapeSubreddit(lastPostAfter: lastPostAfter, sort: sortOption, preventListIdRefresh: true)
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
                } else if (!searchResults.isEmpty || !searchTerm.isEmpty) && !isLoading {
                    SortOptionView(selectedSortOption: $selectedSearchSortOption, selectedTopOption: $selectedSearchTopOption) {
                        clearFeedAndReload(withSearchTerm: "subreddit:\(subredditName) \(searchTerm)")
                    }
                    ContentListView(content: $searchResults, readPosts: readPosts, savedPosts: savedPosts, appTheme: appTheme, textSizePreference: textSizePreference)
                } else {
                    LoadingView(loadingText: "Loading feed...", isLoading: isLoading, textSizePreference: textSizePreference)
                }
            }
            .id(listIdentifier)
        }
        .navigationTitle((titleOverride != nil) ? titleOverride! : subredditName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button(action: { forceCompactMode.toggle() }, label: {
                Image(systemName: appTheme.compactMode ? "rectangle.expand.vertical" : (forceCompactMode ? "rectangle.compress.vertical" : "rectangle.expand.vertical"))
            })
            .disabled(appTheme.compactMode)
            
            let sortMenuView = SubredditUtils.shared.buildSortingMenu(selectedOption: self.sortOption) { option in
                withAnimation { self.sortOption = option }
                clearFeedAndReload()
            }
            sortMenuView
        }
        .onAppear {
            if posts.isEmpty {
                scrapeSubreddit(sort: sortOption)
            }
        }
        .refreshable { clearFeedAndReload() }
        .onChange(of: subredditName) { _, _ in // this handles a navsplitview edge case where swiftui
            // reuses the initial view from the sidebar selection.
            clearFeedAndReload()
        }
        .searchable(text: $searchTerm, prompt: "Search \((titleOverride != nil) ? "OpenArtemisFeed/\(titleOverride!)" : "r/\(subredditName)")")
        .onSubmit(of: .search) { clearFeedAndReload(withSearchTerm: "subreddit:\(subredditName) \(searchTerm)") }
        .onChange(of: searchTerm) { val, _ in if searchTerm.isEmpty { clearFeedAndReload() }}
    }
    
    // MARK: - Private Methods
    
    private func handlePostAppearance(_ postId: String) {
        if !posts.isEmpty && posts.count > Int(Double(posts.count) * 0.85) {
            if postId == posts[Int(Double(posts.count) * 0.85)].id {
                scrapeSubreddit(lastPostAfter: lastPostAfter, sort: sortOption)
            }
        }
    }
    
    private func handlePostTap(_ post: Post, isRead: Bool) {
        coordinator.path.append(PostResponse(post: post))
        if !isRead {
            PostUtils.shared.toggleRead(context: managedObjectContext, postId: post.id)
        }
    }
    
    private struct PostFeedItemView: View {
        let post: Post
        let isRead: Bool
        let forceCompactMode: Bool
        let isSaved: Bool
        let appTheme: AppThemeSettings
        let textSizePreference: TextSizePreference
        let onTap: () -> Void
        
        var body: some View {
            Group {
                PostFeedView(post: post, forceCompactMode: forceCompactMode, isRead: isRead, appTheme: appTheme, textSizePreference: textSizePreference) {
                    onTap()
                }
                .savedIndicator(isSaved)
                .contentShape(Rectangle())
                
                DividerView(frameHeight: 10, appTheme: appTheme)
            }
        }
    }
    
    private func scrapeSubreddit(lastPostAfter: String? = nil, sort: SortOption? = nil, searchTerm: String = "", preventListIdRefresh: Bool = false) {
        self.isLoading = true
        if !preventListIdRefresh { self.listIdentifier = MiscUtils.randomString(length: 4) }
        
        if searchTerm.isEmpty {
            RedditScraper.scrapeSubreddit(subreddit: subredditName, lastPostAfter: lastPostAfter, sort: sort,
                                          trackingParamRemover: trackingParamRemover, over18: over18) { result in
                defer {
                    isLoading = false
                }
                
                switch result {
                case .success(let newPosts):
                    if newPosts.isEmpty && self.retryCount <  3 { // if a load fails, auto retry up to 3 times
                        self.retryCount +=  1
                        self.scrapeSubreddit(lastPostAfter: lastPostAfter, sort: sort, searchTerm: searchTerm, preventListIdRefresh: preventListIdRefresh)
                    } else {
                        self.retryCount =  0
                        for post in newPosts {
                            if !postIDs.contains(post.id) {
                                posts.append(post)
                                postIDs.insert(post.id)
                            }
                        }
                        
                        if let newLastPost = newPosts.last {
                            self.lastPostAfter = newLastPost.id
                        }
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
            justReadDueToScrollingPostIds.removeAll()
            lastPostAfter = ""
            isLoading = false
        }
        
        scrapeSubreddit(sort: sortOption, searchTerm: withSearchTerm)
    }
}
