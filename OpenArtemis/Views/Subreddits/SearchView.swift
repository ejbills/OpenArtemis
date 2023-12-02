//
//  SearchView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/1/23.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var coordinator: NavCoordinator
    
    @State private var inputText: String = ""
    
    var body: some View {
        VStack {
            TextField("Enter subreddit name", text: $inputText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                goToSubreddit()
            }) {
                Text("Go to \(inputText)")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.artemisAccent)
                    .cornerRadius(10)
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
    
    private func goToSubreddit() {
        guard !inputText.isEmpty else {
            // Handle case where inputText is empty
            return
        }
        
        coordinator.path.append(SubredditFeedResponse(subredditName: inputText))
    }
}
