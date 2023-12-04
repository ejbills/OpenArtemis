//
//  SubredditFeedView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/1/23.
//

import SwiftUI

struct SubredditFeedView: View {
    let subredditName: String
    let titleOverride: String?
    @State private var posts: [Post] = []
    @State private var postIDs: Set<String> = Set()
    @State private var lastPostAfter: String = ""
    @EnvironmentObject var trackingParamRemover: TrackingParamRemover
    @State var showImageViewer: Bool = false

    var body: some View {
        Group {
            if !posts.isEmpty {
                ScrollView {
  
                    LazyVStack(spacing: 0) {
                        ForEach(posts, id: \.id) { post in
                            PostFeedView(post: post)
                                .id(post.id)
                                .onAppear {
                                    if post.id == posts[Int(Double(posts.count) * 0.85)].id {
                                        scrapeSubreddit(subredditName, lastPostAfter)
                                    }
                                }
                            DividerView()
                        }
                    }
                }
                .scrollIndicators(.hidden)
            } else {
                LoadingAnimation(loadingText: "Loading Feed...")
                    .padding()
            }
        }
        .id("\(subredditName)-feed-view")
        .navigationTitle((titleOverride != nil) ? titleOverride! : subredditName.localizedCapitalized)
        .onAppear {
            if posts.isEmpty {
                scrapeSubreddit(subredditName)
            }
        }
        .refreshable {
            clearFeedAndReload()
        }
    }
    
    private func scrapeSubreddit(_ subredditName: String, _ lastPostAfter: String? = nil) {
        RedditScraper.scrape(subreddit: subredditName, lastPostAfter: lastPostAfter, trackingParamRemover: trackingParamRemover) { result in
            switch result {
            case .success(let newPosts):
                for post in newPosts {
                    // Check if the post ID is not in the set to avoid duplicates
                    if !postIDs.contains(post.id) {
                        self.posts.append(post)
                        self.postIDs.insert(post.id)
                    }
                }
                
                if let lastPost = newPosts.last {
                    self.lastPostAfter = lastPost.id
                }
            case .failure(let error):
                // Handle error (e.g., display an alert)
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func clearFeedAndReload() {
        self.posts.removeAll()
        self.postIDs.removeAll()
        self.lastPostAfter = ""
        
        scrapeSubreddit(subredditName)
    }
}
