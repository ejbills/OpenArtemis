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
    @State private var mediaSize: CGSize = .zero
    @State private var isSaved: Bool = false
    @State private var hasAppeared: Bool = false
    @State private var isShareSheetPresented: Bool = false // New state to control the share sheet presentation

    
    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 8) {
                Text(post.title)
                    .font(.headline)
                
                Divider()
                
                MediaView(determinedType: post.type, mediaURL: post.mediaURL, thumbnailURL: post.thumbnailURL, title: post.title, mediaSize: $mediaSize)
                
                PostDetailsView(postAuthor: post.author, subreddit: post.subreddit, votes: Int(post.votes) ?? 0)
            }
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: UIColor.systemBackground))
        }        
        .onAppear {
            if !hasAppeared {
                isSaved = PostUtils.shared.fetchSavedPost(context: managedObjectContext, id: post.id) != nil
                hasAppeared.toggle()
            }
        }
        .savedIndicator(isSaved)
        .addGestureActions(
            primaryLeadingAction: GestureAction(symbol: .init(emptyName: "star", fillName: "star.fill"), color: .green, action: {
                withAnimation{
                    isSaved = PostUtils.shared.toggleSaved(context: managedObjectContext, post: post)
                }
            }),
            secondaryLeadingAction: nil,
            primaryTrailingAction: GestureAction(symbol: .init(emptyName: "square.and.arrow.up", fillName: "square.and.arrow.up.fill"), color: .purple, action: {
                MiscUtils.shareItem(item: post.commentsURL)
            }),
            secondaryTrailingAction: nil
        )
        .sheet(isPresented: $isShareSheetPresented) {
                    // Share sheet content
                    ShareSheet(activityItems: [post.commentsURL])
        }
        
    }
}
