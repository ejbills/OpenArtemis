//
//  PostPageView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/2/23.
//

import SwiftUI
import Defaults

private struct AnchorsKey: PreferenceKey {
    // Each key is a comment id. The corresponding value is the
    // .center anchor of that row.
    typealias Value = [String: Anchor<CGPoint>]
    
    static var defaultValue: Value { [:] }
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { $1 }
    }
}

struct PostPageView: View {
    let post: Post
    @State private var comments: [Comment] = []
    @State private var rootComments: [Comment] = []
    @State private var isLoading: Bool = false
    
    //    @State private var disappeardComments: [Comment] = []
    @State private var scrollID: Int? = nil
    @State var topVisibleCommentId: String? = nil
    @State var previousScrollTarget: String? = nil
    
    
    var body: some View {
        GeometryReader{ proxy in
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
                                        .if(rootComments.firstIndex(of: comment) != nil){ view in
                                            view.anchorPreference(
                                                key: AnchorsKey.self,
                                                value: .center
                                            ) { [comment.id: $0] }
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
                    .scrollTargetLayout()
                    
                }
                .onPreferenceChange(AnchorsKey.self) { anchors in
                    topVisibleCommentId = topCommentRow(of: anchors, in: proxy)
                }
                .overlay {
                    if Defaults[.showJumpToNextCommentButton] {
                        VStack {
                            Spacer()
                            Button {
                                withAnimation{
                                    if topVisibleCommentId == nil, let id = rootComments.first?.id {
                                        reader.scrollTo(id, anchor: .top)
                                        topVisibleCommentId = id
                                        return
                                    }
                                    if let topVisibleCommentId {
                                        let topVisibleCommentIndex = rootComments.map {$0.id}.firstIndex(of: topVisibleCommentId) ?? 0
                                        
                                        if topVisibleCommentId == previousScrollTarget {
                                            reader.scrollTo(rootComments[topVisibleCommentIndex ].id, anchor: .top)
                                            previousScrollTarget = rootComments[topVisibleCommentIndex + 1].id
                                        } else {
                                            reader.scrollTo(rootComments[topVisibleCommentIndex + 1].id, anchor: .top)
                                            previousScrollTarget = topVisibleCommentId
                                        }
                                        
                                        
                                    }
                                }
                            } label: {
                                Label("Jump to next Comment", systemImage: "chevron.down")
                                    .labelStyle(.iconOnly)
                            }
                            .padding()
                            .background{
                                Circle()
                                    .foregroundStyle(.thinMaterial)
                            }
                        }
                        .padding()
                    }
                    
                    
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
    

    
    private func topCommentRow(of anchors: AnchorsKey.Value, in proxy: GeometryProxy) -> String? {
        var yBest = CGFloat.infinity
        var answer: String?
        for (row, anchor) in anchors {
            let y = proxy[anchor].y
            guard y >= 0, y < yBest else { continue }
            answer = row
            yBest = y
        }
        return answer
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
