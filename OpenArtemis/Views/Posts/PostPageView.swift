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
    
    @State private var isLoading: Bool = false
    
    var body: some View {
        ScrollView {
            LazyVStack {
                PostFeedView(post: post)
                
                DividerView(frameHeight: 10)
                                
                HStack {
                    Text("Comments")
                        .font(.subheadline)
                    
                    Spacer()
                }
                
                DividerView(frameHeight: 1)
                
                if !comments.isEmpty {
                    ForEach(comments, id: \.id) { comment in
                        CommentView(comment: comment)
                            .frame(maxWidth: .infinity)
                            .padding(.leading, CGFloat(comment.depth) * 10)
                            .onTapGesture {
                                withAnimation(.snappy) {
                                    collapseChildren(parentCommentID: comment.id)
                                }
                            }
                        
                        DividerView(frameHeight: 1)
                    }
                } else {
                    LoadingAnimation(loadingText: "Loading comments from \(post.commentsURL)", isLoading: isLoading)
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
        self.isLoading = true
        
        RedditScraper.scrapeComments(commentURL: commentsURL) { result in
            switch result {
            case .success(let comments):
                for comment in comments {
                    self.comments.append(comment)
                }
            case .failure(let error):
                print("Error: \(error)")
            }
            
            self.isLoading = false
        }
    }
    
    private func collapseChildren(parentCommentID: String) {
        // Find indices of comments that match the parentCommentID
        let matchingIndices = comments.enumerated().filter { $0.element.parentID == parentCommentID }.map { $0.offset }
        
        // Recursively update the matching comments
        for index in matchingIndices {
            comments[index].isCollapsed.toggle()

            // Check if there are child comments before recursing
            collapseChildren(parentCommentID: comments[index].id)
        }
    }



}
