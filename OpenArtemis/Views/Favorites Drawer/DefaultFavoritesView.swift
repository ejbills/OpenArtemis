//
//  DefaultFavoritesView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 3/6/24.
//

import SwiftUI

struct DefaultFavoritesView: View {
    var localFavorites: FetchedResults<LocalSubreddit>
    var concatFavSubs: (() -> String)
    var body: some View {
        DefaultSubredditRowView(title: "Home", iconSystemName: "house.fill", iconColor: .artemisAccent)
            .background(
                NavigationLink(value: SubredditFeedResponse(subredditName: concatFavSubs(), titleOverride: "Home")){
                    EmptyView()
                }
                    .opacity(0)
            )
            .disabledView(disabled: localFavorites.isEmpty)
        
        
        DefaultSubredditRowView(title: "All", iconSystemName: "star.fill", iconColor: colorPalette[0])
            .background(
                // highlights button on tap (cant be modifier or inside child view)
                NavigationLink(value: SubredditFeedResponse(subredditName: "All")) {
                    EmptyView()
                }
                    .opacity(0)
            )
        
        DefaultSubredditRowView(title: "Popular", iconSystemName: "lightbulb.fill", iconColor: colorPalette[2])
            .background(
                NavigationLink(value: SubredditFeedResponse(subredditName: "Popular")) {
                    EmptyView()
                }
                    .opacity(0)
            )
        
        DefaultSubredditRowView(title: "Saved", iconSystemName: "bookmark.fill", iconColor: colorPalette[4])
            .background(
                NavigationLink(value: SubredditFeedResponse(subredditName: "Saved")) {
                    EmptyView()
                }
                    .opacity(0)
            )
    }
}
