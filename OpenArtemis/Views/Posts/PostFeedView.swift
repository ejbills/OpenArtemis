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
    @Default(.compactMode) var compactMode
    
    let post: Post
    @State private var mediaSize: CGSize = .zero
    @State private var isSaved: Bool = false
    @State private var hasAppeared: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            renderContent()
        }
        .padding(8)
        .themedBackground()
        .onAppear {
            if !hasAppeared {
                isSaved = PostUtils.shared.fetchSavedPost(context: managedObjectContext, id: post.id) != nil
                hasAppeared.toggle()
            }
        }
        .savedIndicator(isSaved)
        .addGestureActions(
            primaryLeadingAction: GestureAction(symbol: .init(emptyName: "star", fillName: "star.fill"), color: .green, action: {
                withAnimation {
                    isSaved = PostUtils.shared.toggleSaved(context: managedObjectContext, post: post)
                }
            }),
            secondaryLeadingAction: nil,
            primaryTrailingAction: GestureAction(symbol: .init(emptyName: "square.and.arrow.up", fillName: "square.and.arrow.up.fill"), color: .purple, action: {
                MiscUtils.shareItem(item: post.commentsURL)
            }),
            secondaryTrailingAction: nil
        )
    }

    @ViewBuilder
    private func renderContent() -> some View {
        if !compactMode {
            renderNormalContent()
        } else {
            renderCompactContent()
        }
    }

    private func renderNormalContent() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.title)
                .font(.headline)
            
            if !post.tag.isEmpty {
                DetailTagView(data: post.tag, color: getColorFromInputString(post.tag).opacity(0.25))
            }
                        
            MediaView(determinedType: post.type, mediaURL: post.mediaURL, thumbnailURL: post.thumbnailURL, title: post.title, mediaSize: $mediaSize)
            
            PostDetailsView(postAuthor: post.author, subreddit: post.subreddit, time: post.time, votes: Int(post.votes) ?? 0)
        }
    }

    private func renderCompactContent() -> some View {
        HStack {
            VStack {
                MediaView(determinedType: post.type, mediaURL: post.mediaURL, thumbnailURL: post.thumbnailURL, title: post.title, mediaSize: $mediaSize)
                    .frame(width: roughCompactWidth, height: roughCompactHeight) // lock media to a square
                
                Spacer()
                    .padding(.bottom, -16) // push to the top of the vstack, also reclaim the trailing padding
            }
            
            VStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(post.title)
                    
                    if !post.tag.isEmpty {
                        DetailTagView(data: post.tag, color: getColorFromInputString(post.tag).opacity(0.25))
                    }
                    
                    PostDetailsView(postAuthor: post.author, subreddit: post.subreddit, time: post.time, votes: Int(post.votes) ?? 0)
                }
            }
            
            Spacer()
        }
    }
}

