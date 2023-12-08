//
//  PostPageView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/2/23.
//

import SwiftUI
import Defaults

struct PostPageView: View {
    @Default(.showJumpToNextCommentButton) private var showJumpToNextCommentButton
    
    let post: Post
  
    @State private var commentUtils = CommentUtils()
    @State private var comments: [Comment] = []
    @State private var rootComments: [Comment] = []
    @State private var postBody: String? = nil
    @State private var isLoading: Bool = false
    
    @State private var scrollID: Int? = nil
    @State var topVisibleCommentId: String? = nil
    @State var previousScrollTarget: String? = nil
    @FetchRequest(sortDescriptors: []) var savedComments: FetchedResults<SavedComment>
    @FetchRequest(sortDescriptors: []) var savedPosts: FetchedResults<SavedPost>

    var body: some View {
        GeometryReader{ proxy in
            ScrollViewReader { reader in
                ScrollView {
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
                                
                                Text(postBody)
                                    .font(.body)
                            }
                            .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .background(tagBgColor)
                            .cornerRadius(6)
                            .padding(.horizontal, 8)
                            .padding(.bottom, 8)
                        }

                        DividerView(frameHeight: 10)
                        
                        if !comments.isEmpty {
                            ForEach(Array(comments.enumerated()), id: \.1.id) { (index, comment) in
                                if !comment.isCollapsed {
                                    Group {
                                        CommentView(comment: comment,
                                                    numberOfChildren: comment.isRootCollapsed ?
                                                    commentUtils.getNumberOfDescendants(for: comment, in: comments) :
                                                        0)
                                        
                                            // next comment tracker
                                            .if(rootComments.firstIndex(of: comment) != nil){ view in
                                                view.anchorPreference(
                                                    key: CommentUtils.AnchorsKey.self,
                                                    value: .center
                                                ) { [comment.id: $0] }
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.leading, CGFloat(comment.depth) * 10)
                                            .padding(.vertical, 4)
                                    }
                                    .background(Color(uiColor: UIColor.systemBackground))
                                    .onTapGesture {
                                        withAnimation(.snappy(duration: 0.25)) {
                                            comments[index].isRootCollapsed.toggle()
                                            collapseChildren(parentCommentID: comment.id, rootCollapsedStatus: comments[index].isRootCollapsed)
                                        }
                                    }
                                    .addGestureActions(
                                        primaryLeadingAction: GestureAction(symbol: .init(emptyName: "chevron.up", fillName: "chevron.up"), color: .blue, action: {
                                            withAnimation(.snappy(duration: 0.25)) {
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
                                        secondaryLeadingAction: GestureAction(symbol: .init(emptyName: "star", fillName: "star.fill"), color: .green, action: {
                                            CommentUtils().toggleSaved(comment: comment,post: post,savedComments: savedComments)
                                        }),
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
                            LoadingAnimation(loadingText: "Loading comments...")
                        }
                    }                    
                }
                .onPreferenceChange(CommentUtils.AnchorsKey.self) { anchors in
                    DispatchQueue.main.async {
                        topVisibleCommentId = commentUtils.topCommentRow(of: anchors, in: proxy)
                    }
                }
                .overlay {
                    if showJumpToNextCommentButton {
                        HStack {
                            Spacer()
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
        }
        .frame(maxWidth: UIScreen.main.bounds.width,
               maxHeight: UIScreen.main.bounds.height) // prevents animated comment loading from twitching
        .scrollIndicators(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("\(comments.count) Comments")
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
            case .success(let result):
                withAnimation(.snappy) {
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
