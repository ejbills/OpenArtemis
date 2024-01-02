//
//  SavedView.swift
//  OpenArtemis
//
//  Created by daniel on 08/12/23.
//

import SwiftUI
import CoreData

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
            ThemedList(appTheme: appTheme, stripStyling: true) {
                ForEach(mixedMediaLinks, id: \.self) { mixedMediaTuple in
                    var isSaved: Bool {
                        switch mixedMediaTuple {
                        case .post(let post, _):
                            savedPosts.contains { $0.id == post.id }
                        case .comment(let comment, _):
                            savedComments.contains { $0.id == comment.id }
                        default:
                            false
                        }
                    }
                    
                    MixedContentView(content: mixedMediaTuple, appTheme: appTheme)
                            .savedIndicator(isSaved)
                        
                    DividerView(frameHeight: 10, appTheme: appTheme)
                }
                
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
    
    let content: MixedMedia
    let isRead: Bool
    let appTheme: AppThemeSettings
        
    @State var isLoadingCommentPost: Bool = false
    
    init(content: MixedMedia, isRead: Bool = false, appTheme: AppThemeSettings) {
        self.content = content
        self.isRead = isRead
        self.appTheme = appTheme
    }
    
    var body: some View {
        switch content {
        case .post(let post, _):
            PostFeedView(post: post, isRead: isRead, appTheme: appTheme)
                .onTapGesture {
                    coordinator.path.append(PostResponse(post: post))
                    
                    if !isRead {
                        PostUtils.shared.toggleRead(context: managedObjectContext, postId: post.id)
                    }
                }
        case .comment(let comment, _):
            CommentView(comment: comment, numberOfChildren: 0, appTheme: appTheme)
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
                        RedditScraper.scrapePostFromCommentsURL(url: commentURL, trackingParamRemover: nil) { result in
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
            SubredditRowView(subredditName: subreddit.subreddit)
        }
    }
}
