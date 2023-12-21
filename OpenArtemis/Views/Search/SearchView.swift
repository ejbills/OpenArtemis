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
    @State private var searchResults: [MixedMedia] = [] // Add state to store search results
    
    @FetchRequest(sortDescriptors: []) var savedPosts: FetchedResults<SavedPost>
    @FetchRequest(sortDescriptors: []) var savedComments: FetchedResults<SavedComment>

    var body: some View {
        ThemedScrollView {
            VStack {
                HStack {
                    TextField("Enter search query", text: $inputText)
                        .padding()
                        .textFieldStyle(.roundedBorder)
                    
                    Button(action: {
                        performSearch()
                    }) {
                        Text("Search")
                            .foregroundStyle(Color.artemisAccent)
                    }
                }
                
                // Display search results using ForEach
                ForEach(searchResults, id: \.self) { result in
                    MixedContentView(content: result, savedPosts: savedPosts, savedComments: savedComments)
                }
                
                Spacer()
            }
            .padding()
            //        .themedBackground(isDarker: true)
        }
    }

    private func performSearch() {
        // Call the RedditScraper search method and update the searchResults state
        RedditScraper.search(query: inputText) { result in
            switch result {
            case .success(let results):
                DispatchQueue.main.async {
                    searchResults = results
                }
            case .failure(let error):
                print("Search error: \(error)")
            }
        }
    }
}
