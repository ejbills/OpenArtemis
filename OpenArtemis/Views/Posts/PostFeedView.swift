//
//  PostFeedView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/28/23.
//

import SwiftUI
import CoreData
import Defaults

struct PostFeedView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    let post: Post
    let forceAuthorToDisplay: Bool
    let appTheme: AppThemeSettings
    @State private var mediaSize: CGSize = .zero
    @State private var metadataThumbnailURL: String? = nil
    @State private var isSaved: Bool = false
    @State private var hasAppeared: Bool = false
    
    init(post: Post, forceAuthorToDisplay: Bool = false, appTheme: AppThemeSettings) {
        self.post = post
        self.forceAuthorToDisplay = forceAuthorToDisplay
        self.appTheme = appTheme
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            renderContent()
        }
        .padding(8)
        .themedBackground(appTheme: appTheme)
        .onAppear {
            if !hasAppeared {
                isSaved = PostUtils.shared.fetchSavedPost(context: managedObjectContext, id: post.id) != nil
                
                // grab the thumbnail from article opengraph metadata
                let type = post.type
                if (type == "video" || type == "gallery" || type == "article") && post.thumbnailURL == nil {
                    MediaUtils.fetchImageURL(urlString: post.mediaURL.originalURL) { imageURL in
                        if let imageURL, !imageURL.isEmpty {
                            metadataThumbnailURL = imageURL
                        }
                    }
                }
                hasAppeared.toggle()
            }
        }
        .savedIndicator(isSaved)
        .gestureActions(
            primaryLeadingAction: GestureAction(symbol: .init(emptyName: "star", fillName: "star.fill"), color: .green, action: {
                withAnimation {
                    isSaved = PostUtils.shared.toggleSaved(context: managedObjectContext, post: post)
                }
            }),
            secondaryLeadingAction: nil,
            primaryTrailingAction: GestureAction(symbol: .init(emptyName: "square.and.arrow.up", fillName: "square.and.arrow.up.fill"), color: .purple, action: {
                MiscUtils.shareItem(item: post.commentsURL)
            }),
            secondaryTrailingAction: GestureAction(symbol: .init(emptyName: "safari", fillName: "safari.fill"), color: .brown, action: {
                MiscUtils.openInBrowser(urlString: post.commentsURL)
            })
        )
        .contextMenu(menuItems: {
            ShareLink(item: URL(string: post.commentsURL)!)
            Button(action: {
                withAnimation {
                    isSaved = PostUtils.shared.toggleSaved(context: managedObjectContext, post: post)
                }
            }) {
                Text(isSaved ? "Unsave" : "Save")
                Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
            }
            Button(action: {
                MiscUtils.openInBrowser(urlString: post.commentsURL)
            }) {
                Text("Open in in-app browser")
                Image(systemName: "safari")
            }
        })
    }

    @ViewBuilder
    private func renderContent() -> some View {
        if !appTheme.compactMode {
            renderNormalContent()
        } else {
            renderCompactContent()
        }
    }

    private func renderNormalContent() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            TitleTagView(title: post.title, domain: "", tag: post.tag)
                        
            MediaView(determinedType: post.type, mediaURL: post.mediaURL, thumbnailURL: getThumbnailURL(), title: post.title, appTheme: appTheme, mediaSize: $mediaSize)
            
            PostDetailsView(postAuthor: post.author, subreddit: post.subreddit, time: post.time, votes: Int(post.votes) ?? 0, commentsCount: Int(post.commentsCount) ?? 0, forceAuthorToDisplay: forceAuthorToDisplay, appTheme: appTheme)
        }
    }

    private func renderCompactContent() -> some View {
        HStack(alignment: .top) {
            VStack {
                MediaView(determinedType: post.type, mediaURL: post.mediaURL, thumbnailURL: getThumbnailURL(), title: post.title, appTheme: appTheme, mediaSize: $mediaSize)
                    .frame(width: roughCompactWidth, height: roughCompactHeight) // lock media to a square
            }
            
            VStack(alignment: .leading, spacing: 4) {
                TitleTagView(title: post.title, domain: appTheme.showOriginalURL ? post.mediaURL.originalURL : post.mediaURL.privateURL, tag: post.tag)
                PostDetailsView(postAuthor: post.author, subreddit: post.subreddit, time: post.time, votes: Int(post.votes) ?? 0, commentsCount: Int(post.commentsCount) ?? 0, forceAuthorToDisplay: forceAuthorToDisplay,  appTheme: appTheme)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
    
    private func getThumbnailURL() -> String? {
        return post.thumbnailURL != nil ? post.thumbnailURL : metadataThumbnailURL
    }
}
