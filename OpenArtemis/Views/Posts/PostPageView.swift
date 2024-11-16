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
    @Default(.showJumpToNextCommentButton) private var showJumpToNextCommentButton
    
    let post: Post
    var commentsURLOverride: String?
    let appTheme: AppThemeSettings
    let textSizePreference: TextSizePreference
    
    @FetchRequest(
        entity: SavedPost.entity(),
        sortDescriptors: []
    ) var savedPosts: FetchedResults<SavedPost>

    @FetchRequest(
        entity: SavedComment.entity(),
        sortDescriptors: []
    ) var savedComments: FetchedResults<SavedComment>
    
    @State private var comments: [Comment] = []
    @State private var rootComments: [Comment] = []
    @State private var postBody: String? = nil
    @State private var isLoading: Bool = false
    @State private var isLoadAllCommentsPressed = false
    @State private var sortOption: SortOption = Defaults[.defaultPostPageSorting]
    
    @State private var scrollID: Int? = nil
    @State var topVisibleCommentId: String? = nil
    @State var previousScrollTarget: String? = nil
    
    @State private var listIdentifier = "" // this handles generating a new identifier on load to prevent stale data
    
    @EnvironmentObject var trackingParamRemover: TrackingParamRemover
    
    var body: some View {
        GeometryReader{ proxy in
            ScrollViewReader { reader in
                ThemedList(appTheme: appTheme, textSizePreference: textSizePreference, stripStyling: true) {
                    var isSaved: Bool {
                        savedPosts.contains(where: { $0.id == post.id })
                    }
                    
                    PostFeedView(post: post, forceAuthorToDisplay: true, appTheme: appTheme, textSizePreference: textSizePreference, useLargeThumbnail: false)
                        .savedIndicator(isSaved)
                    
                    if let postBody = postBody {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Post Body")
                                    .font(textSizePreference.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            
                            Markdown(postBody)
                                .markdownTheme(.artemisMarkdown(fontSize: textSizePreference.bodyFontSize))
                        }
                        .padding(EdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 8))
                    }
                    
                    DividerView(frameHeight: 10, appTheme: appTheme)
                    
                    if !comments.isEmpty {
                        if commentsURLOverride != nil && !isLoadAllCommentsPressed {
                            Button(action: {
                                clearCommentsAndReload()
                            }) {
                                Group {
                                    Label("Load all other comments", systemImage: "rectangle.expand.vertical")
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .padding(8)
                            .font(textSizePreference.caption)
                            .italic()
                            .foregroundStyle(Color.artemisAccent)
                            .disabled(isLoadAllCommentsPressed)
                            
                            Divider()
                        }
                        
                        
                        ForEach(Array(comments.enumerated()), id: \.1.id) { (index, comment) in
                            var isSaved: Bool {
                                savedComments.contains(where: { $0.id == comment.id })
                            }
                            
                            if !comment.isCollapsed {
                                Group {
                                    CommentView(comment: comment,
                                                numberOfChildren: comment.isRootCollapsed ?
                                                CommentUtils.shared.getNumberOfDescendants(for: comment, in: comments) : 0,
                                                postAuthor: post.author,
                                                appTheme: appTheme,
                                                textSizePreference: textSizePreference)
                                    .frame(maxWidth: .infinity)
                                    .padding(.leading, CGFloat(comment.depth) * 10)
                                }
                                .themedBackground(appTheme: appTheme)
                                .savedIndicator(isSaved)
                                .onTapGesture {
                                    withAnimation(.smooth(duration: 0.35)) {
                                        comments[index].isRootCollapsed.toggle()
                                        collapseChildren(parentCommentID: comment.id, rootCollapsedStatus: comments[index].isRootCollapsed)
                                    }
                                }
                                .gestureActions(
                                    primaryLeadingAction: GestureAction(symbol: .init(emptyName: comments[index].isRootCollapsed ? "chevron.up" : "chevron.down", fillName: comments[index].isRootCollapsed ? "chevron.down" : "chevron.up"), color: .blue, action: {
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
                                        CommentUtils.shared.toggleSaved(context: managedObjectContext, comment: comment)
                                    }),
                                    primaryTrailingAction: GestureAction(symbol: .init(emptyName: "square.and.arrow.up", fillName: "square.and.arrow.up.fill"), color: .purple, action: {
                                        MiscUtils.shareItem(item: comment.directURL)
                                    }),
                                    secondaryTrailingAction: GestureAction(symbol: .init(emptyName: "safari", fillName: "safari.fill"), color: .brown, action: {
                                        MiscUtils.openInBrowser(urlString: comment.directURL)
                                    })
                                )
                                .contextMenu(ContextMenu(menuItems: {
                                    ShareLink(item: URL(string: "\(post.commentsURL)\(comment.id.replacingOccurrences(of: "t1_", with: ""))")!)
                                    
                                    Button(action: {
                                        CommentUtils.shared.toggleSaved(context: managedObjectContext, comment: comment)
                                    }) {
                                        Text("Toggle save")
                                        Image(systemName: "bookmark")
                                    }
                                    Button(action: {
                                        MiscUtils.openInBrowser(urlString: comment.directURL)
                                    }) {
                                        Text("Open in in-app browser")
                                        Image(systemName: "safari")
                                    }
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
                        LoadingView(loadingText: "Loading comments...", isLoading: isLoading, textSizePreference: textSizePreference)
                    }
                }
                .id(listIdentifier)
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
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("\((Int(post.commentsCount) ?? 0).roundedWithAbbreviations) Comments")
        .toolbar {
            let sortMenuView = PostUtils.shared.buildSortingMenu(selectedOption: self.sortOption) { option in
                withAnimation { self.sortOption = option }
                clearCommentsAndReload()
            }
            sortMenuView
        }
        .refreshable {
            clearCommentsAndReload()
        }
        .onAppear {
            if comments.isEmpty {
                if let commentsURLOverride {
                    scrapeComments(commentsURLOverride, sort: sortOption, trackingParamRemover: trackingParamRemover)
                } else {
                    scrapeComments(post.commentsURL, sort: sortOption, trackingParamRemover: trackingParamRemover)
                }
            }
        }
    }
    
    private func scrapeComments(_ commentsURL: String, sort: SortOption? = nil, trackingParamRemover: TrackingParamRemover) {
        self.isLoading = true
        self.listIdentifier = MiscUtils.randomString(length: 4)
        
        RedditScraper.scrapeComments(commentURL: commentsURL, sort: sort, trackingParamRemover: trackingParamRemover) { result in
            switch result {
            case .success(let result):
                for comment in result.comments {
                    self.comments.append(comment)
                    
                    if comment.depth == 0 {
                        self.rootComments.append(comment)
                    }
                }
                
                if let postBody = result.postBody, !(postBody.isEmpty) {
                    self.postBody = postBody
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
    
    private func clearCommentsAndReload() {
        withAnimation {
            self.comments.removeAll()
            self.isLoadAllCommentsPressed = true
        }
        
        scrapeComments(post.commentsURL, sort: sortOption, trackingParamRemover: trackingParamRemover)
    }
    
    private func buildSortingMenu() -> some View {
        Menu(content: {
            ForEach(SortOption.allCases) { opt in
                Button {
                    sortOption = opt
                    clearCommentsAndReload()
                } label: {
                    HStack {
                        Text(opt.rawVal.value.capitalized)
                        Spacer()
                        Image(systemName: opt.rawVal.icon)
                            .foregroundColor(Color.artemisAccent)
                            .font(.system(size: 17, weight: .bold))
                    }
                }
            }
        }, label: {
            Image(systemName: sortOption.rawVal.icon)
                .foregroundColor(Color.artemisAccent)
        })
    }
}
