//
//  PostDetailsView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/5/23.
//

import SwiftUI

struct PostDetailsView: View {
    @EnvironmentObject var coordinator: NavCoordinator
    
    let postAuthor: String
    let subreddit: String
    let votes: Int
    
    var body: some View {
        HStack {
            DetailTagView(icon: "person", data: postAuthor)
            
            Spacer()
            
            DetailTagView(icon: "location", data: subreddit)
                .onTapGesture {
                    coordinator.path.append(SubredditFeedResponse(subredditName: subreddit))
                }
            
            DetailTagView(icon: "arrow.up", data: votes.roundedWithAbbreviations)
        }
    }
}
