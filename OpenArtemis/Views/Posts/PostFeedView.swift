//
//  PostFeedView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/28/23.
//

import SwiftUI
import AVKit

struct PostFeedView: View {
    @EnvironmentObject var coordinator: NavCoordinator
    
    let post: Post
    
    @State private var mediaSize: CGSize = .zero
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            Text(post.title)
                .font(.headline)
                .padding(.vertical, 8) // vertical padding here so it also includes the gesture background
            Divider()
            
            HStack {
                Spacer()
                
                MediaView(determinedType: post.type, mediaURL: post.mediaURL, thumbnailURL: post.thumbnailURL, title: post.title, mediaSize: $mediaSize)
                
                Spacer()
            }
            .padding(.vertical, 8) // vertical padding here so it also includes the gesture background
            HStack {
                DetailTagView(icon: "person", data: post.author)
                
                DetailTagView(icon: "location", data: post.subreddit)
                    .onTapGesture {
                        coordinator.path.append(SubredditFeedResponse(subredditName: post.subreddit))
                    }
                
                DetailTagView(icon: "arrow.up", data: Int(post.votes)?.roundedWithAbbreviations ?? "")
            }
            .padding(.vertical, 8) // vertical padding here so it also includes the gesture background
        }
        .background(Color(uiColor: UIColor.systemBackground))
        .padding(.horizontal, 8)
        .addGestureActions(
            primaryLeadingAction: GestureAction(symbol: .init(emptyName: "star", fillName: "star.fill"), color: .green, action: {}),
            secondaryLeadingAction: nil,
            primaryTrailingAction: GestureAction(symbol: .init(emptyName: "square.and.arrow.up", fillName: "square.and.arrow.up.fill"), color: .blue, action: {}),
            secondaryTrailingAction: nil
        )
        .frame(maxWidth: .infinity)
    }
}
