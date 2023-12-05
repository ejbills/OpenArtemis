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
    @State private var rootComments: [Comment] = []
    @State private var isLoading: Bool = false
    @State private var visibleRootComments: [Comment] = []
    //    @State private var disappeardComments: [Comment] = []
    @State private var scrollID: Int? = nil
    @State var visibleRootComment: Comment? = nil
    var body: some View {
        ScrollViewReader { reader in
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
                                CommentView(comment: comment, numberOfChildren:comment.isRootCollapsed ? getNumberOfDescendants(for: comment, in: comments) : 0)
                                    .id(comment.id)
                                    .onAppear{
                                        if comment.parentID == nil {
                                            visibleRootComments.append(comment)
                                        }
                                    }
                                    .onDisappear{
                                        if comment.parentID == nil {
                                            visibleRootComment = visibleRootComments.first
                                            visibleRootComments = visibleRootComments.filter { $0.id != comment.id}
                                        }
                                    }
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
                                    .background{
                                        if visibleRootComment == comment {
                                            Color.red
                                        } else if visibleRootComments.firstIndex(of: comment) != nil{
                                            Color.yellow
                                        }
                                        
                                        else {
                                            Color(uiColor: UIColor.systemBackground)
                                        }
                                    }
                                    .addGestureActions(
                                        primaryLeadingAction: GestureAction(symbol: .init(emptyName: "chevron.up", fillName: "chevron.up"), color: .blue, action: {
                                            withAnimation(.snappy) {
                                                if comment.parentID == nil {
                                                    comments[index].isRootCollapsed.toggle()
                                                    collapseChildren(parentCommentID: comment.id, rootCollapsedStatus: comments[index].isRootCollapsed)
                                                } else {
                                                    //Find the root comment by traversing up the tree
                                                    if let rootComment = findRootComment(comment: comment), let rootIndex = comments.firstIndex(of: rootComment) {
                                                        comments[rootIndex].isRootCollapsed = true
                                                        collapseChildren(parentCommentID: rootComment.id, rootCollapsedStatus: comments[rootIndex].isRootCollapsed)
                                                    }
                                                }
                                            }
                                        }),
                                        secondaryLeadingAction: GestureAction(symbol: .init(emptyName: "star", fillName: "star.fill"), color: .green, action: {saveComment(comment: comment)}),
                                        primaryTrailingAction: GestureAction(symbol: .init(emptyName: "square.and.arrow.up", fillName: "square.and.arrow.up.fill"), color: .purple, action: {
                                            shareComment(comment: comment, post: post)
                                        }),
                                        secondaryTrailingAction: nil
                                    )
                                    .contextMenu(ContextMenu(menuItems: {
                                        ShareLink(item: URL(string: "\(post.commentsURL)\(comment.id.replacingOccurrences(of: "t1_", with: ""))")!)
                                    }))
                                DividerView(frameHeight: 1)
                                    .padding(.leading, CGFloat(comment.depth) * 10)
                            }
                        }
                    } else {
                        LoadingAnimation(loadingText: "Loading comments...", isLoading: isLoading)
                    }
                }
                
            }
            .scrollTargetLayout()
        }
    .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                } label: {
                    Label("Jump to next Comment", systemImage: "chevron.down")
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
    
    private func saveComment(comment: Comment) {
        
    }
    
    private func shareComment(comment: Comment, post: Post) {
        
    }
    
    private func scrapeComments(_ commentsURL: String) {
        self.isLoading = true
        
        RedditScraper.scrapeComments(commentURL: commentsURL) { result in
            switch result {
            case .success(let comments):
                for comment in comments {
                    self.comments.append(comment)
                    rootComments = comments.filter { $0.parentID == nil }
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
