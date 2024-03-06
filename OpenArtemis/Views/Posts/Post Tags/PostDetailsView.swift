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
    let appTheme: AppThemeSettings
    let textSizePreference: TextSizePreference
    
    var body: some View {
        HStack(spacing: 4) {
          
          PostTagsPill(infos: [
            .init(icon: "signpost.right.and.left.fill", label: subreddit, onTap: { coordinator.path.append(SubredditFeedResponse(subredditName: subreddit)) }),
            .init(icon: "person", label: postAuthor, onTap: { coordinator.path.append(ProfileResponse(username: postAuthor)) })
          ], appTheme: appTheme, textSizePreference: textSizePreference)
          
          if !appTheme.compactMode { // upvotes get pushed all the way acrossed the view in compact mode, it looks weird. disabling it here
              Spacer()
          }
          
          PostTagsPill(infos: [
            .init(icon: "clock", label: TimeFormatUtil().formatTimeAgo(fromUTCString: time)),
            .init(icon: "arrow.up", label: votes.roundedWithAbbreviations),
            .init(icon: "bubble.right", label: commentsCount.roundedWithAbbreviations),
          ], appTheme: appTheme, textSizePreference: textSizePreference)
        }
        .foregroundStyle(appTheme.tagBackground ? .primary : .secondary)
    }
}
