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
    
    let postAuthor: String
    let subreddit: String
    let time: String
    let votes: Int
    let commentsCount: Int
    let appTheme: AppThemeSettings
    
    var body: some View {
        HStack(spacing: 4) {
            DetailTagView(icon: "location", data: subreddit, appTheme: appTheme)
                .onTapGesture {
                    coordinator.path.append(SubredditFeedResponse(subredditName: subreddit))
                }
                .foregroundColor(appTheme.highlightSubreddit ? Color.artemisAccent : appTheme.tagBackground ? .primary : .secondary)
            
            if appTheme.showAuthor {
                DetailTagView(icon: "person", data: postAuthor, appTheme: appTheme)
                    .onTapGesture {
                        coordinator.path.append(ProfileResponse(username: postAuthor))
                    }
            }
            
            if !appTheme.compactMode { // upvotes get pushed all the way acrossed the view in compact mode, it looks weird. disabling it here
                Spacer()
            }
            
            DetailTagView(icon: "clock", data: TimeFormatUtil().formatTimeAgo(fromUTCString: time), appTheme: appTheme)
            
            DetailTagView(icon: "arrow.up", data: votes.roundedWithAbbreviations, appTheme: appTheme)
            
            DetailTagView(icon: "rectangle.3.group.bubble.left", data: commentsCount.roundedWithAbbreviations, appTheme: appTheme)
        }
        .foregroundStyle(appTheme.tagBackground ? .primary : .secondary)
    }
}
