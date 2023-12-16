//
//  PostPageView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/2/23.
//

import SwiftUI
import Defaults
import MarkdownUI

struct PostPageView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) private var colorScheme
    @Default(.showJumpToNextCommentButton) private var showJumpToNextCommentButton
    
    let post: Post
    
    @State private var comments: [Comment] = []
    @State private var rootComments: [Comment] = []
    @State private var perViewSavedComments: Set<String> = []
    @State private var postBody: String? = nil
    @State private var isLoading: Bool = false
    
    @State private var scrollID: Int? = nil
    @State var topVisibleCommentId: String? = nil
    @State var previousScrollTarget: String? = nil
    
    @State private var postLoaded: Bool = false
    @EnvironmentObject var trackingParamRemover: TrackingParamRemover
    
    var body: some View {
        GeometryReader{ proxy in
            ScrollViewReader { reader in
                ThemedScrollView {
                    LazyVStack(spacing: 0) {
                        PostFeedView(post: post)
                        if let postBody = postBody {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Post Body")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                                
                                Markdown(postBody)
                            }
                            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                            .background(tagBgColor)
                            .cornerRadius(6)
                            .padding(.horizontal, 8)
                            .padding(.bottom, 8)
                        }
                        
                        Divider()
                        
                        if !comments.isEmpty {
                            ForEach(Array(comments.enumerated()), id: \.1.id) { (index, comment) in
                                if !comment.isCollapsed {
                                    Group {
                                        CommentView(comment: comment,
                                                    numberOfChildren: comment.isRootCollapsed ?
                                                    CommentUtils.shared.getNumberOfDescendants(for: comment, in: comments) : 0)
                                        .frame(maxWidth: .infinity)
                                        .padding(.leading, CGFloat(comment.depth) * 10)
                                    }
                                    .themedBackground(isDarker: true)
                                    .savedIndicator(perViewSavedComments.contains(comment.id))
                                    .onTapGesture {
                                        withAnimation(.smooth(duration: 0.35)) {
                                            comments[index].isRootCollapsed.toggle()
                                            collapseChildren(parentCommentID: comment.id, rootCollapsedStatus: comments[index].isRootCollapsed)
                                        }
                                    }
                                    .addGestureActions(
                                        primaryLeadingAction: GestureAction(symbol: .init(emptyName: "chevron.up", fillName: "chevron.up"), color: .blue, action: {
                                            withAnimation(.smooth(duration: 0.35)) {
                                                if comment.parentID == nil {
                                                    comments[index].isRootCollapsed.toggle()
                                                    collapseChildren(parentCommentID: comment.id, rootCollapsedStatus: comments[index].isRootCollapsed)
                                                } else {
                                                    if let rootComment = findRootComment(comment: comment), let rootIndex = comments.firstIndex(of: rootComment) {
                                                        reader.scrollTo(comments[rootIndex].id)
                                                        comments[rootIndex].isRootCollapsed = true
                                                        collapseChildren(parentCommentID: rootComment.id, rootCollapsedStatus: comments[rootIndex].isRootCollapsed)
                                                    }
                                                }
                                            }
                                        }),
                                        secondaryLeadingAction: GestureAction(symbol: .init(emptyName: "star", fillName: "star.fill"), color: .green, action: {
                                                let commentSaveBool = CommentUtils.shared.toggleSaved(context: managedObjectContext, comment: comment)
                                                
                                                if commentSaveBool {
                                                    perViewSavedComments.insert(comment.id)
                                                } else {
                                                    perViewSavedComments.remove(comment.id)
                                                }
                                        }),
                                        primaryTrailingAction: GestureAction(symbol: .init(emptyName: "square.and.arrow.up", fillName: "square.and.arrow.up.fill"), color: .purple, action: {
                                            MiscUtils.shareItem(item: comment.directURL)
                                        }),
                                        secondaryTrailingAction: nil
                                    )
                                    .contextMenu(ContextMenu(menuItems: {
                                        ShareLink(item: URL(string: "\(post.commentsURL)\(comment.id.replacingOccurrences(of: "t1_", with: ""))")!)
                                    }))
                                    Divider()
                                        .padding(.leading, CGFloat(comment.depth) * 10)
                                        // next comment tracker
                                        .if(rootComments.firstIndex(of: comment) != nil) { view in
                                            view.anchorPreference(
                                                key: CommentUtils.AnchorsKey.self,
                                                value: .center
                                            ) { [comment.id: $0] }
                                        }
                                }
                            }
                        } else {
                            LoadingAnimation(loadingText: "Loading comments...")
                        }
                    }
                    .themedBackground()
                }
                .commentSkipper(
                    showJumpToNextCommentButton: $showJumpToNextCommentButton,
                    topVisibleCommentId: $topVisibleCommentId,
                    previousScrollTarget: $previousScrollTarget,
                    rootComments: rootComments,
                    reader: reader
                )
                .onPreferenceChange(CommentUtils.AnchorsKey.self) { anchors in
                    DispatchQueue.main.async {
                        topVisibleCommentId = CommentUtils.shared.topCommentRow(of: anchors, in: proxy)
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("\(comments.count) Comments")
        .onAppear {
            if comments.isEmpty {
                scrapeComments(post.commentsURL,trackingParamRemover: trackingParamRemover)
            }
            
            if !postLoaded {
                let savedComments = CommentUtils.shared.fetchSavedComments(context: managedObjectContext)
                for savedComment in savedComments {
                    if let commentID = savedComment.id {
                        perViewSavedComments.insert(commentID)
                    }
                }
                
                postLoaded.toggle()
            }
        }
    }
    
    private func scrapeComments(_ commentsURL: String, trackingParamRemover: TrackingParamRemover) {
        self.isLoading = true
        
        RedditScraper.scrapeComments(commentURL: commentsURL, trackingParamRemover: trackingParamRemover) { result in
            switch result {
            case .success(let result):
                withAnimation(.smooth) {
                    for comment in result.comments {
                        self.comments.append(comment)
                        
                        if comment.depth == 0 {
                            self.rootComments.append(comment)
                        }
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
