//
//  SavedView.swift
//  OpenArtemis
//
//  Created by daniel on 08/12/23.
//

import SwiftUI
import CoreData
import Defaults

struct SavedView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(
        entity: SavedPost.entity(),
        sortDescriptors: []
    ) var savedPosts: FetchedResults<SavedPost>
    
    @FetchRequest(
        entity: SavedComment.entity(),
        sortDescriptors: []
    ) var savedComments: FetchedResults<SavedComment>
    
    @State var mixedMediaLinks: [MixedMedia] = []
    
    let appTheme: AppThemeSettings
    let textSizePreference: TextSizePreference
    
    var body: some View {
        if mixedMediaLinks.isEmpty {
            HStack{
                VStack{
                    Text("In the lunar emptiness, Artemis, Apollo, and the moon share a quiet dance, their solitude echoing through the celestial silence...")
                        .opacity(0.5)
                        .padding()
                    Image(systemName: "moon.fill")
                        .foregroundStyle(.black.opacity(0.8))
                        .font(.system(size: 20))
                }
            } .onAppear {
                updateFeed()
            }
            
        } else {
            ThemedList(appTheme: appTheme, textSizePreference: textSizePreference, stripStyling: true) {
                ContentListView(
                    content: $mixedMediaLinks,
                    savedPosts: savedPosts,
                    savedComments: savedComments,
                    appTheme: appTheme,
                    textSizePreference: textSizePreference,
                    preventRead: true
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                updateFeed()
            }
            .refreshable {
                updateFeed()
            }
            .navigationTitle("Saved")
        }
    }
    
    /// Updates the mixed media feed by loading saved posts and comments from CoreData,
    /// mapping them into `MixedMediaTuple` elements, and sorting the array by date in descending order.
    func updateFeed() {
        mixedMediaLinks = []
        
        // Map the saved posts from CoreData to the mixedMediaLinks array
        let posts = savedPosts.map { post in
            let postTuple = PostUtils.shared.savedPostToPost(context: managedObjectContext, post: post)
            return MixedMedia.post(postTuple.1, date: postTuple.0)
        }
        
        // Map the saved comments from CoreData to the mixedMediaLinks array
        let comments = savedComments.map { savedComment in
            let commentTuple = CommentUtils.shared.savedCommentToComment(savedComment)
            return MixedMedia.comment(commentTuple.1, date: commentTuple.0)
        }
        
        // Combine posts and comments into mixedMediaLinks array
        mixedMediaLinks += posts
        mixedMediaLinks += comments
        
        DateSortingUtils.sortMixedMediaByDateDescending(&mixedMediaLinks)
    }
}


///This is a view that combines both Posts and Comments
struct MixedContentView: View {
    @EnvironmentObject var coordinator: NavCoordinator
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @Default(.useLargeThumbnailForMediaPreview) var useLargeThumbnailForMediaPreview

    let content: MixedMedia
    let isRead: Bool
    let appTheme: AppThemeSettings
    let textSizePreference: TextSizePreference
    
    @State var isLoadingCommentPost: Bool = false
    
    init(content: MixedMedia, isRead: Bool = false, appTheme: AppThemeSettings, textSizePreference: TextSizePreference) {
        self.content = content
        self.isRead = isRead
        self.appTheme = appTheme
        self.textSizePreference = textSizePreference
    }
    
    var body: some View {
        switch content {
        case .post(let post, _):
            PostFeedView(post: post, isRead: isRead, appTheme: appTheme, textSizePreference: textSizePreference,
                         useLargeThumbnail: useLargeThumbnailForMediaPreview) {
                coordinator.path.append(PostResponse(post: post))
                
                if !isRead {
                    PostUtils.shared.markRead(context: managedObjectContext, postId: post.id)
                }
            }
        case .comment(let comment, _):
            CommentView(comment: comment, numberOfChildren: 0, appTheme: appTheme, textSizePreference: textSizePreference)
                .loadingOverlay(isLoading: isLoadingCommentPost, radius: 0)
                .gestureActions(primaryLeadingAction: GestureAction(symbol: .init(emptyName: "star", fillName: "star.fill"), color: .green, action: {
                    CommentUtils.shared.toggleSaved(context: managedObjectContext, comment: comment)
                }), secondaryLeadingAction: nil, primaryTrailingAction: nil, secondaryTrailingAction: nil)
                .onTapGesture {
                    if !isLoadingCommentPost {
                        withAnimation {
                            isLoadingCommentPost = true
                        }
                        
                        let commentURL = comment.directURL
                        RedditScraper.scrapePostFromURL(url: commentURL, trackingParamRemover: nil) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let post):
                                    coordinator.path.append(PostResponse(post: post, commentsURLOverride: commentURL))
                                case .failure(let failure):
                                    print("Error: \(failure)")
                                }
                                
                                isLoadingCommentPost = false
                            }
                        }
                    }
                }
        case .subreddit(let subreddit):
            SubredditRowView(subredditName: subreddit.subreddit, skipSaved: true)
        }
    }
}
