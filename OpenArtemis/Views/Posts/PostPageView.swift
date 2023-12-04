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
                    ForEach(Array(comments.enumerated()), id: \.1.id) { (index, comment) in
                        CommentView(comment: comment)
                            .frame(maxWidth: .infinity)
                            .padding(.leading, CGFloat(comment.depth) * 10)
                            .onTapGesture {
                                withAnimation(.snappy) {
                                    comments[index].isCollapsed.toggle()
                                    collapseChildren(parentCommentID: comment.id, rootCollapsedStatus: comments[index].isCollapsed)
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
    
    private func collapseChildren(parentCommentID: String, rootCollapsedStatus: Bool) {
        // Find indices of comments that match the parentCommentID
        let matchingIndices = self.comments.enumerated().filter { $0.element.parentID == parentCommentID }.map { $0.offset }
        
        // Recursively update the matching comments
        for index in matchingIndices {
            self.comments[index].isCollapsed = rootCollapsedStatus

            // Check if there are child comments before recursing
            collapseChildren(parentCommentID: self.comments[index].id, rootCollapsedStatus: rootCollapsedStatus)
        }
    }



}
