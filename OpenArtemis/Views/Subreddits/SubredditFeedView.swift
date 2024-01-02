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
    @EnvironmentObject var coordinator: NavCoordinator
    @EnvironmentObject var trackingParamRemover: TrackingParamRemover
    @Default(.over18) var over18
    
    let subredditName: String
    let titleOverride: String?
    let appTheme: AppThemeSettings
    
    @State private var posts: [Post] = []
    @State private var postIDs: Set<String> = Set()
    @State private var lastPostAfter: String = ""
    @State private var sortOption: SortOption = .best
    @State private var isLoading: Bool = false
    
    @Environment(\.managedObjectContext) var managedObjectContext
        
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
                if !posts.isEmpty {
                    ForEach(posts, id: \.id) { post in
                        var isRead: Bool {
                            readPosts.contains(where: { $0.readPostId == post.id })
                        }
                        var isSaved: Bool {
                            savedPosts.contains { $0.id == post.id }
                        }
                        
                        PostFeedView(post: post, isRead: isRead, appTheme: appTheme)
                            .savedIndicator(isSaved)
                            .id(post.id)
                            .contentShape(Rectangle())
                            .onAppear {
                                handlePostAppearance(post.id)
                            }
                            .onTapGesture {
                                coordinator.path.append(PostResponse(post: post))
                                
                                if !isRead {
                                    PostUtils.shared.toggleRead(context: managedObjectContext, postId: post.id)
                                }
                            }

                        DividerView(frameHeight: 10, appTheme: appTheme)
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

    private func scrapeSubreddit(_ lastPostAfter: String? = nil, sort: SortOption? = nil) {
        self.isLoading = true

        RedditScraper.scrapeSubreddit(subreddit: subredditName, lastPostAfter: lastPostAfter, sort: sort,
                                      trackingParamRemover: trackingParamRemover, over18: over18) { result in
            handleScrapeResult(result)
        }
    }
    
    private func handleScrapeResult(_ result: Result<[Post], Error>) {
        switch result {
        case .success(let newPosts):
            for post in newPosts {
                if !postIDs.contains(post.id) {
                    posts.append(post)
                    postIDs.insert(post.id)
                }
            }

            if let lastPost = newPosts.last {
                lastPostAfter = lastPost.id
            }
        case .failure(let error):
            print("Error: \(error.localizedDescription)")
        }

        isLoading = false
    }
    
    private func clearFeedAndReload() {
        withAnimation(.smooth) {
            posts.removeAll()
            postIDs.removeAll()
            lastPostAfter = ""
            isLoading = false
        }
        
        scrapeSubreddit(sort: sortOption)
    }
}
