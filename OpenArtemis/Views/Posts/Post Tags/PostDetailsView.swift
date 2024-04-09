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
    let forceAuthorToDisplay: Bool
    let forceCompactMode: Bool
    let appTheme: AppThemeSettings
    let textSizePreference: TextSizePreference
    
    var body: some View {
        HStack(spacing: 4) {
            DetailTagView(icon: "location", data: subreddit, appTheme: appTheme, textSizePreference: textSizePreference) {
                coordinator.navToAndStore(forData: NavigationPayload.subredditFeed(SubredditFeedResponse(subredditName: subreddit)))
            }
            .foregroundColor(appTheme.highlightSubreddit ? Color.artemisAccent : appTheme.tagBackground ? .primary : .secondary)
            
            if appTheme.showAuthor || forceAuthorToDisplay {
                DetailTagView(icon: "person", data: postAuthor, appTheme: appTheme, textSizePreference: textSizePreference) {
                    coordinator.navToAndStore(forData: NavigationPayload.profile(ProfileResponse(username: postAuthor)))
                }
                .foregroundColor(appTheme.highlightAuthor ? Color.artemisAccent : appTheme.tagBackground ? .primary : .secondary)
            }
            
            if !appTheme.compactMode && !forceCompactMode {
                Spacer()
            }
            
            DetailTagView(icon: "clock", data: TimeFormatUtil().formatTimeAgo(fromUTCString: time), appTheme: appTheme, textSizePreference: textSizePreference)
            
            DetailTagView(icon: "arrow.up", data: votes.roundedWithAbbreviations, appTheme: appTheme, textSizePreference: textSizePreference)
            
            DetailTagView(icon: "rectangle.3.group.bubble.left", data: commentsCount.roundedWithAbbreviations, appTheme: appTheme, textSizePreference: textSizePreference)
        }
        .foregroundStyle(appTheme.tagBackground ? .primary : .secondary)
    }
}
