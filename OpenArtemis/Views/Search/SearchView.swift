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
    
    let appTheme: AppThemeSettings
    
    var body: some View {
        VStack(spacing: 0) {
            let isSubredditSearch = searchType == "sr"
            ThemedList(appTheme: appTheme, stripStyling: !isSubredditSearch && !searchResults.isEmpty) {
                if !isLoading {
                    if searchResults.isEmpty {
                        // sorting hints!
                        Text("""
                            Use the following search parameters to narrow your results:
                            
                            subreddit:subreddit
                            Find submissions in "subreddit"

                            author:username
                            Find submissions by "username"

                            site:example.com
                            Find submissions from "example.com"

                            url:text
                            Search for "text" in url

                            selftext:text
                            Search for "text" in self post contents
                            """)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(searchResults, id: \.self) { result in
                            MixedContentView(content: result, savedPosts: savedPosts, savedComments: savedComments, appTheme: appTheme)
                            if !isSubredditSearch {
                                DividerView(frameHeight: 10, appTheme: appTheme)
                            }
                        }
                    }
                } else {
                    LoadingView(loadingText: "Loading search...", isLoading: true)
                }
            }
        }

        .themedBackground(isDarker: true, appTheme: appTheme)
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing:
                Picker("Search Type", selection: $searchType) {
                    Text("Subreddits").tag("sr")
                    Text("Posts").tag("")
                }
        )
        .searchable(text: $inputText)
        .onSubmit(of: .search) {
            performSearch()
        }
        .animation(.default, value: inputText)
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
