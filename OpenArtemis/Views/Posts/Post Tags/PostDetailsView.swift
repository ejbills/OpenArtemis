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
  
  @State private var showingOrigin = true
  
  var body: some View {
    ZStack {
      
      PostTagsPill(
        active: showingOrigin,
        infos: [
        .init(icon: "signpost.right.and.left.fill", label: subreddit, onTap: { coordinator.path.append(SubredditFeedResponse(subredditName: subreddit)) }),
        .init(icon: "person", label: postAuthor, onTap: { coordinator.path.append(ProfileResponse(username: postAuthor)) })
      ], appTheme: appTheme, textSizePreference: textSizePreference)
      .scaleEffect(!showingOrigin ? 0.85 : 1, anchor: .leading)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.trailing, 64)
      .allowsHitTesting(showingOrigin)
      .overlay {
        if !showingOrigin {
          Color.invertedPrimary.opacity(0.001).frame(maxWidth: .infinity, maxHeight: .infinity)
            .highPriorityGesture(TapGesture().onEnded { withAnimation(.spring) { showingOrigin = true } })
            .transition(.identity)
        }
      }
      .zIndex(2)
      
      //          if !appTheme.compactMode { // upvotes get pushed all the way acrossed the view in compact mode, it looks weird. disabling it here
      //              Spacer()
      //          }
      
      PostTagsPill(
        active: !showingOrigin,
        infos: [
        .init(icon: "clock", label: TimeFormatUtil().formatTimeAgo(fromUTCString: time)),
        .init(icon: "arrow.up", label: votes.roundedWithAbbreviations),
        .init(icon: "bubble.right", label: commentsCount.roundedWithAbbreviations),
      ], appTheme: appTheme, textSizePreference: textSizePreference)
      .scaleEffect(showingOrigin ? 0.85 : 1, anchor: .trailing)
      .frame(maxWidth: .infinity, alignment: .trailing)
      .padding(.leading, 64)
      .allowsHitTesting(!showingOrigin)
      .overlay {
        if showingOrigin {
          Color.invertedPrimary.opacity(0.001).frame(maxWidth: .infinity, maxHeight: .infinity)
            .highPriorityGesture(TapGesture().onEnded { withAnimation(.spring) { showingOrigin = false } })
            .transition(.identity)
        }
      }
      .zIndex(showingOrigin ? 1 : 3)
    }
    .foregroundStyle(appTheme.tagBackground ? .primary : .secondary)
  }
}
