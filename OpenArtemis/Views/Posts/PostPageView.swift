//
//  PostPageView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/2/23.
//

import SwiftUI

struct PostPageView: View {
    let post: Post
    @State private var comments: [Comment] = []
    
    var body: some View {
        ScrollView {
            VStack {
                PostFeedView(post: post)
                
                DividerView(frameHeight: 10)
                                
                HStack {
                    Text("Comments")
                        .font(.subheadline)
                    
                    Spacer()
                }
                
                if !comments.isEmpty {
                    ForEach(comments, id: \.id) { comment in
                        CommentView(comment: comment)
                        
                        DividerView(frameHeight: 5)
                    }
                } else {
                    LoadingAnimation(loadingText: "Loading comments from \(post.commentsURL)")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if comments.isEmpty {
                scrapeComments(post.commentsURL)
            }
        }
    }
    
    private func scrapeComments(_ commentsURL: String) {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        RedditScraper.scrapeComments(commentURL: commentsURL) { result in
            switch result {
            case .success(let comments):
                for comment in comments {
                    self.comments.append(comment)
                }
                let endTime = CFAbsoluteTimeGetCurrent() // Stop the timer
                let elapsedTime = endTime - startTime
                print("Time taken: \(elapsedTime) seconds")
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}
