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
    @Default(.compactMode) var compactMode
    
    let subredditName: String
    let titleOverride: String?
    
    @State private var posts: [Post] = []
    @State private var postIDs: Set<String> = Set()
    @State private var lastPostAfter: String = ""
    @State private var sortOption: SubListingSortOption = .best
    @State private var isLoading: Bool = false
    
    @FetchRequest(sortDescriptors: []) var savedPosts: FetchedResults<SavedPost>
    
    // MARK: - Body
    var body: some View {
        Group {
            if !posts.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(posts, id: \.id) { post in
                            Group {
                                if compactMode {
                                    PostFeedView(post: post)
                                        .frame(height: roughCompactHeight + 16) // apply height frame, accounts for padding
                                } else {
                                    PostFeedView(post: post)
                                }
                            }
                            .id(post.id)
                            .contentShape(Rectangle())
                            .onAppear {
                                handlePostAppearance(post)
                            }
                            .onTapGesture {
                                coordinator.path.append(PostResponse(post: post))
                            }
                            
                            DividerView(frameHeight: 10)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            } else {
                LoadingAnimation(loadingText: "Loading Feed...")
            }
        }
        .id("\(subredditName)-feed-view")
        .navigationTitle((titleOverride != nil) ? titleOverride! : subredditName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            buildSortingMenu()
        }
        .onAppear {
            if posts.isEmpty {
                scrapeSubreddit(subredditName)
            }
        }
        .refreshable {
            clearFeedAndReload()
        }
    }
    
    // MARK: - Private Methods
    
    private func handlePostAppearance(_ post: Post) {
        if !posts.isEmpty && posts.count > Int(Double(posts.count) * 0.85) {
            if post.id == posts[Int(Double(posts.count) * 0.85)].id {
                scrapeSubreddit(subredditName, lastPostAfter, sort: sortOption)
            }
        }
    }

    private func buildSortingMenu() -> some View {
        Menu(content: {
            ForEach(SubListingSortOption.allCases) { opt in
                if case .top(_) = opt {
                    Menu {
                        ForEach(SubListingSortOption.TopListingSortOption.allCases, id: \.self) { topOpt in
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

    private func scrapeSubreddit(_ subredditName: String, _ lastPostAfter: String? = nil, sort: SubListingSortOption? = nil) {
        self.isLoading = true

        RedditScraper.scrapeSubreddit(subreddit: subredditName, lastPostAfter: lastPostAfter, sort: sort, 
                                      trackingParamRemover: trackingParamRemover, over18: over18) { result in
            handleScrapeResult(result)
        }
    }
    
    private func handleScrapeResult(_ result: Result<[Post], Error>) {
        switch result {
        case .success(let newPosts):
            withAnimation(.smooth) {
                for post in newPosts {
                    if !postIDs.contains(post.id) {
                        posts.append(post)
                        postIDs.insert(post.id)
                    }
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
        
        scrapeSubreddit(subredditName, sort: sortOption)
    }
}
