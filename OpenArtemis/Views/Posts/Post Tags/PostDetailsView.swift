//
//  PostDetailsView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/5/23.
//

import Defaults
import SwiftUI

struct PostDetailsView: View {
    @EnvironmentObject var coordinator: NavCoordinator
    @Default(.compactMode) var compactMode
    
    let postAuthor: String
    let subreddit: String
    let votes: Int
    
    var body: some View {
        HStack {
            DetailTagView(icon: "person", data: postAuthor)
            
            DetailTagView(icon: "location", data: subreddit)
                .onTapGesture {
                    coordinator.path.append(SubredditFeedResponse(subredditName: subreddit))
                }
            
            if !compactMode { // upvotes get pushed all the way acrossed the view in compact mode, it looks weird. disabling it here
                Spacer()
            }
            
            DetailTagView(icon: "arrow.up", data: votes.roundedWithAbbreviations)
        }
    }
}
