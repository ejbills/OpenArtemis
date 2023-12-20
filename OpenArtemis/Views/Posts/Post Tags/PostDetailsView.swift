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
    @Default(.showAuthor) var showAuthor
    @Default(.tagBackground) var tagBackground
    @Default(.highlightSubreddit) var highlightSubreddit
    
    let postAuthor: String
    let subreddit: String
    let time: String
    let votes: Int
    let commentsCount: Int
    
    var body: some View {
        HStack(spacing: 4) {
            DetailTagView(icon: "location", data: subreddit)
                .onTapGesture {
                    coordinator.path.append(SubredditFeedResponse(subredditName: subreddit))
                }
                .foregroundColor(highlightSubreddit ? Color.artemisAccent : tagBackground ? .primary : .secondary)
            
            if showAuthor {
                DetailTagView(icon: "person", data: postAuthor)
            }
            
            if !compactMode { // upvotes get pushed all the way acrossed the view in compact mode, it looks weird. disabling it here
                Spacer()
            }
            
            DetailTagView(icon: "clock", data: TimeFormatUtil().formatTimeAgo(fromUTCString: time))
            
            DetailTagView(icon: "arrow.up", data: votes.roundedWithAbbreviations)
            
            DetailTagView(icon: "rectangle.3.group.bubble.left", data: commentsCount.roundedWithAbbreviations)
        }
        .foregroundStyle(tagBackground ? .primary : .secondary)
    }
}
