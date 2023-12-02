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
            
            Divider()
            
            HStack {
                Spacer()
                
                MediaView(determinedType: post.type, mediaURL: post.mediaURL, thumbnailURL: post.thumbnailURL, mediaSize: $mediaSize)
                
                Spacer()
            }
            
            HStack {
                DetailTagView(icon: "person", data: post.author)
                
                DetailTagView(icon: "location", data: post.subreddit)
                    .onTapGesture {
                        coordinator.path.append(SubredditFeedResponse(subredditName: post.subreddit))
                    }
                
                DetailTagView(icon: "arrow.up", data: post.score)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity)
    }
}
