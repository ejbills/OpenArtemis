//
//  DefaultFavoritesView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 3/6/24.
//

import SwiftUI
import Defaults

struct DefaultFavoritesView: View {
    @Default(.commentColorPalette) var commentColorPalette
    
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
        
        
        DefaultSubredditRowView(title: "All", iconSystemName: "star.fill", iconColor: commentColorPalette[0])
            .background(
                // highlights button on tap (cant be modifier or inside child view)
                NavigationLink(value: SubredditFeedResponse(subredditName: "all")) {
                    EmptyView()
                }
                    .opacity(0)
            )
        
        DefaultSubredditRowView(title: "Popular", iconSystemName: "lightbulb.fill", iconColor: commentColorPalette[2])
            .background(
                NavigationLink(value: SubredditFeedResponse(subredditName: "popular")) {
                    EmptyView()
                }
                    .opacity(0)
            )
        
        DefaultSubredditRowView(title: "Saved", iconSystemName: "bookmark.fill", iconColor: commentColorPalette[4])
            .background(
                NavigationLink(value: SubredditFeedResponse(subredditName: "Saved")) {
                    EmptyView()
                }
                    .opacity(0)
            )
    }
}
