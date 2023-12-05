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
                
                DividerView(frameHeight: 1)
                
                HStack {
                    Text("Comments")
                        .font(.title3)
                        .padding(.leading)
                    
                    Spacer()
                }
                
                DividerView(frameHeight: 1)
                
                if !comments.isEmpty {
                    ForEach(Array(comments.enumerated()), id: \.1.id) { (index, comment) in
                        if !comment.isCollapsed {
                            CommentView(comment: comment, numberOfChildren: getNumberOfDescendants(for: comment, in: comments))
                                .frame(maxWidth: .infinity)
                                .padding(.leading, CGFloat(comment.depth) * 10)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.snappy) {
                                        comments[index].isRootCollapsed.toggle()
                                        collapseChildren(parentCommentID: comment.id, rootCollapsedStatus: comments[index].isRootCollapsed)
                                    }
                                }
                                .padding(.vertical, 4)
                                .background(Color(uiColor: UIColor.systemBackground))
                                .addGestureActions(
                                    primaryLeadingAction: GestureAction(symbol: .init(emptyName: "chevron.up", fillName: "chevron.up"), color: .blue, action: {
                                        withAnimation(.snappy) {
                                            if comment.parentID == nil {
                                                comments[index].isRootCollapsed.toggle()
                                                collapseChildren(parentCommentID: comment.id, rootCollapsedStatus: comments[index].isRootCollapsed)
                                            } else {
                                                //Find the root comment by traversing up the tree
                                                if var rootComment = findRootComment(comment: comment), let rootIndex = comments.firstIndex(of: rootComment) {
                                                    comments[rootIndex].isRootCollapsed = true
                                                    collapseChildren(parentCommentID: rootComment.id, rootCollapsedStatus: comments[rootIndex].isRootCollapsed)
                                                }
                                            }
                                        }
                                    }),
                                    secondaryLeadingAction: GestureAction(symbol: .init(emptyName: "star", fillName: "star.fill"), color: .green, action: {}),
                                    primaryTrailingAction: GestureAction(symbol: .init(emptyName: "square.and.arrow.up", fillName: "square.and.arrow.up.fill"), color: .purple, action: {}),
                                    secondaryTrailingAction: nil
                                )
                            
                            DividerView(frameHeight: 1)
                                .padding(.leading, CGFloat(comment.depth) * 10)
                        }
                    }
                } else {
                    LoadingAnimation(loadingText: "Loading comments...", isLoading: isLoading)
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
            
            if !self.comments[index].isRootCollapsed { // catch a child comment that is collapsed being collapsed again
                // Check if there are child comments before recursing
                collapseChildren(parentCommentID: self.comments[index].id, rootCollapsedStatus: rootCollapsedStatus)
            }
        }
    }
    
    private func findRootComment(comment: Comment) -> Comment? {
        var currentComment = comment
        while let parentID = currentComment.parentID {
            if let parentComment = comments.first(where: { $0.id == parentID }) {
                currentComment = parentComment
            } else {
                // Parent comment not found, break the loop
                break
            }
        }
        return currentComment
    }
    
}
