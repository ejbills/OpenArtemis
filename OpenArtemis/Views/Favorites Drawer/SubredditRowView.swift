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
            getColorFromInputString(subreddit.name ?? "")
                .frame(width: 30, height: 30)
                .clipShape(Circle())

            VStack(alignment: .leading) {
                Text(subreddit.name ?? "")
                Text("Tap to go to r/\(subreddit.name ?? "")")
                    .foregroundColor(.secondary)
            }

            if editMode {
                Spacer()

                Button(action: {
                    removeFromSubredditFavorites()
                }) {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.red)
                        .font(.title)
                        .padding(.trailing)
                }
            }
        }
        .background(
            NavigationLink(value: SubredditFeedResponse(subredditName: subreddit.name ?? "")) {
                EmptyView()
            }
            .opacity(0)
            .disabled(editMode)
        )
    }
}
