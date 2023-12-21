//
//  SubredditRowView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/2/23.
//

import SwiftUI
import CoreData

struct SubredditRowView: View {
    var subredditName: String
    var editMode: Bool = false
    var removeFromSubredditFavorites: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            if editMode, let removeFromFavorites = removeFromSubredditFavorites {
                Button(action: {
                    removeFromFavorites()
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 20))
                }
            }
            
            getColorFromInputString(subredditName)
                .frame(width: 30, height: 30)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(subredditName)
            }
        }
        .background(
            NavigationLink(value: SubredditFeedResponse(subredditName: subredditName)) {
                EmptyView()
            }
            .opacity(0)
            .disabled(editMode)
        )
        .contextMenu {
            if let removeFromFavorites = removeFromSubredditFavorites {
                Button(action: {
                    removeFromFavorites()
                }) {
                    Label("Remove from Favorites", systemImage: "trash")
                        .foregroundColor(.red)
                }
            }
        }
    }
}
