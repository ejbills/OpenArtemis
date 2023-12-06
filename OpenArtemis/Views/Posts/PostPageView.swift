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
    @State private var postBody: String? = nil
    @State private var isLoading: Bool = false
    
    var body: some View {
        ScrollView {
            LazyVStack {
                PostFeedView(post: post)
                
                if let postBody = postBody {
                    Text(postBody)
                        .font(.body)
                        .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                
                DividerView(frameHeight: 10)
                
                
                if !comments.isEmpty {
                    ForEach(Array(comments.enumerated()), id: \.1.id) { (index, comment) in
                        if !comment.isCollapsed {
                            CommentView(comment: comment)
                                .id(comment.id)
                                .frame(maxWidth: .infinity)
                                .padding(.leading, CGFloat(comment.depth) * 10)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.snappy(duration: 0.25)) {
                                        comments[index].isRootCollapsed.toggle()
                                        
                                        collapseChildren(parentCommentID: comment.id, rootCollapsedStatus: comments[index].isRootCollapsed)
                                    }
                                }
                            
                            DividerView(frameHeight: 1)
                        }
                    }
                    
                } else {
                    LoadingAnimation(loadingText: "Loading comments...")
                        .padding()
                }
            }
        }
        .frame(maxWidth: UIScreen.main.bounds.width,
               maxHeight: UIScreen.main.bounds.height) // prevents animated comment loading from twitching
        .scrollIndicators(.hidden)
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
            case .success(let result):
                withAnimation(.snappy) {
                    for comment in result.comments {
                        self.comments.append(comment)
                    }
                    
                    if let postBody = result.postBody, !(postBody.isEmpty) {
                        self.postBody = postBody
                    }
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
            
            if !self.comments[index].isRootCollapsed { // catch a child comment that is collapsed being collapsed again
                // Check if there are child comments before recursing
                collapseChildren(parentCommentID: self.comments[index].id, rootCollapsedStatus: rootCollapsedStatus)
            }
        }
    }
}
