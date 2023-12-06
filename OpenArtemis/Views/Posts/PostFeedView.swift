//
//  PostFeedView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/28/23.
//

import SwiftUI

struct PostFeedView: View {
    @EnvironmentObject var coordinator: NavCoordinator
    
    let post: Post
    
    @State private var mediaSize: CGSize = .zero
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.title)
                .font(.headline)
            
            Divider()
                
            MediaView(determinedType: post.type, mediaURL: post.mediaURL, thumbnailURL: post.thumbnailURL, title: post.title, mediaSize: $mediaSize)
                        
            PostDetailsView(postAuthor: post.author, subreddit: post.subreddit, votes: Int(post.votes) ?? 0)
        }
        .padding(8)
        .frame(maxWidth: .infinity)
    }
}
