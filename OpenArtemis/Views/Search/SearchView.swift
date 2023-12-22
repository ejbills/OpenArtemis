//
//  SearchView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/1/23.
//

import SwiftUI
import Defaults

struct SearchView: View {
    @EnvironmentObject var coordinator: NavCoordinator
    @EnvironmentObject var trackingParamRemover: TrackingParamRemover
    @Default(.over18) var over18
    
    @State private var inputText: String = ""
    @State private var searchType: String = "sr"
    @State private var searchResults: [MixedMedia] = []
    @State private var isLoading: Bool = false
    
    @FetchRequest(sortDescriptors: []) var savedPosts: FetchedResults<SavedPost>
    @FetchRequest(sortDescriptors: []) var savedComments: FetchedResults<SavedComment>

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Enter search query", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                
                Button(action: {
                    performSearch()
                }) {
                    Text("Search")
                        .foregroundStyle(Color.artemisAccent)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            if searchType == "sr" {
                if !isLoading {
                    ThemedList {
                        ForEach(searchResults, id: \.self) { result in
                            MixedContentView(content: result, savedPosts: savedPosts, savedComments: savedComments)
                        }
                    }
                    .listStyle(.plain)
                    
                } else {
                    LoadingAnimation(loadingText: "Loading subreddits...", isLoading: isLoading)
                }
            } else {
                ThemedScrollView {
                    if !isLoading {
                        LazyVStack(spacing: 0) {
                            ForEach(searchResults, id: \.self) { result in
                                MixedContentView(content: result, savedPosts: savedPosts, savedComments: savedComments)
                                DividerView(frameHeight: 10)
                            }
                        }
                    } else {
                        LoadingAnimation(loadingText: "Loading posts...", isLoading: isLoading)
                    }
                }
            }
        }
        .themedBackground(isDarker: true)
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing:
                Picker("Search Type", selection: $searchType) {
                    Text("Subreddits").tag("sr")
                    Text("Posts").tag("")
                }
        )
        .onChange(of: searchType) { oldVal, _ in
            clearFeed()
        }
    }

    private func performSearch() {
        isLoading = true

        RedditScraper.search(query: inputText, searchType: searchType,
                             trackingParamRemover: trackingParamRemover,
                             over18: over18) { result in
            defer {
                isLoading = false
            }
            
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
    
    private func clearFeed() {
        searchResults.removeAll()
        isLoading = false
    }
}
