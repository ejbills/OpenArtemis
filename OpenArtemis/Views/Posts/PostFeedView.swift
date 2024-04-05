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
    let forceCompactMode: Bool
    let isRead: Bool
    let appTheme: AppThemeSettings
    let textSizePreference: TextSizePreference
    let onTap: (() -> Void)?
    
    @State private var mediaSize: CGSize = .zero
    @State private var metadataThumbnailURL: String? = nil
    @State private var hasAppeared: Bool = false
    
    init(post: Post, forceAuthorToDisplay: Bool = false, forceCompactMode: Bool = false, isRead: Bool = false, appTheme: AppThemeSettings, textSizePreference: TextSizePreference, onTap: (() -> Void)? = nil) {
        self.post = post
        self.forceAuthorToDisplay = forceAuthorToDisplay
        self.forceCompactMode = forceCompactMode
        self.isRead = isRead
        self.appTheme = appTheme
        self.textSizePreference = textSizePreference
        self.onTap = onTap
    }

    var body: some View {
        AnimatedButtonPress(content: {
            VStack(alignment: .leading, spacing: 8) {
                renderContent()
                    .markRead(isRead: isRead)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .themedBackground(appTheme: appTheme)
            .onAppear {
                if !hasAppeared {
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
            .gestureActions(
                primaryLeadingAction: GestureAction(symbol: .init(emptyName: "star", fillName: "star.fill"), color: .green, action: {
                    PostUtils.shared.toggleSaved(context: managedObjectContext, post: post)
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
                    PostUtils.shared.toggleSaved(context: managedObjectContext, post: post)
                }) {
                    Text("Toggle save")
                    Image(systemName: "bookmark")
                }
                Button(action: {
                    MiscUtils.openInBrowser(urlString: post.commentsURL)
                }) {
                    Text("Open in in-app browser")
                    Image(systemName: "safari")
                }
            })
        }, onTap: { onTap?() })
    }

    @ViewBuilder
    private func renderContent() -> some View {
        if !appTheme.compactMode && !forceCompactMode {
            renderNormalContent()
        } else {
            renderCompactContent()
        }
    }

    private func renderNormalContent() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            TitleTagView(title: post.title, domain: "", tag: post.tag, textSizePreference: textSizePreference)
            
            // text posts do not have any metadata to display, so avoid rendering this entirely if it's a text post.
            if post.type != "text" {
                MediaView(determinedType: post.type, mediaURL: post.mediaURL, thumbnailURL: getThumbnailURL(), title: post.title, forceCompactMode: forceCompactMode, appTheme: appTheme, textSizePreference: textSizePreference, mediaSize: $mediaSize)
            }
            
            PostDetailsView(postAuthor: post.author, subreddit: post.subreddit, time: post.time, votes: Int(post.votes) ?? 0, commentsCount: Int(post.commentsCount) ?? 0, forceAuthorToDisplay: forceAuthorToDisplay, forceCompactMode: forceCompactMode, appTheme: appTheme, textSizePreference: textSizePreference)
        }
    }

    private func renderCompactContent() -> some View {
        HStack(alignment: .top) {
            VStack {
                MediaView(determinedType: post.type, mediaURL: post.mediaURL, thumbnailURL: getThumbnailURL(), title: post.title, forceCompactMode: forceCompactMode, appTheme: appTheme, textSizePreference: textSizePreference, mediaSize: $mediaSize)
                    .frame(width: roughCompactWidth, height: roughCompactHeight) // lock media to a square
            }
            
            VStack(alignment: .leading, spacing: 4) {
                TitleTagView(title: post.title, domain: appTheme.showOriginalURL ? post.mediaURL.originalURL : post.mediaURL.privateURL, 
                             tag: post.tag, textSizePreference: textSizePreference)
                PostDetailsView(postAuthor: post.author, subreddit: post.subreddit, time: post.time, votes: Int(post.votes) ?? 0, commentsCount: Int(post.commentsCount) ?? 0, forceAuthorToDisplay: forceAuthorToDisplay, forceCompactMode: forceCompactMode, appTheme: appTheme, textSizePreference: textSizePreference)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
    
    private func getThumbnailURL() -> String? {
        return post.thumbnailURL != nil ? post.thumbnailURL : metadataThumbnailURL
    }
}
