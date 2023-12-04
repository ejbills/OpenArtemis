//
//  SubredditRowView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/2/23.
//

import SwiftUI
import CoreData

struct SubredditRowView: View {
    var subreddit: LocalSubreddit
    var editMode: Bool
    var removeFromSubredditFavorites: () -> Void
    
    var body: some View {
        HStack { 
            if editMode {
                
                Button(action: {
                    removeFromSubredditFavorites()
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 20))
                }
            }
            
            getColorFromInputString(subreddit.name ?? "")
                .frame(width: 30, height: 30)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(subreddit.name ?? "")
                Text("Tap to go to r/\(subreddit.name ?? "")")
                    .foregroundColor(.secondary)
            }
            
            
        }
        .background(
            NavigationLink(value: SubredditFeedResponse(subredditName: subreddit.name ?? "")) {
                EmptyView()
            }
                .opacity(0)
                .disabled(editMode)
        )
        .contextMenu(ContextMenu(menuItems: {
            Button{
                removeFromSubredditFavorites()
            } label: {
                Label("Remove from Favorites", systemImage: "trash")
                    .foregroundColor(.red)
            }
            
        }))
    }
}
