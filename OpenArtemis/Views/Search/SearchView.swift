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
            if searchType == "sr" {
                if !isLoading {
                    ThemedList(appTheme: appTheme) {
                        ForEach(searchResults, id: \.self) { result in
                            MixedContentView(content: result, savedPosts: savedPosts, savedComments: savedComments, appTheme: appTheme)
                        }
                    }
                } else {
                    LoadingAnimation(loadingText: "Loading subreddits...", isLoading: true)
                }
            } else {
                ThemedList(appTheme: appTheme, stripStyling: true) {
                    if !isLoading {
                        ForEach(searchResults, id: \.self) { result in
                            MixedContentView(content: result, savedPosts: savedPosts, savedComments: savedComments, appTheme: appTheme)
                            DividerView(frameHeight: 10, appTheme: appTheme)
                        }
                    } else {
                        LoadingAnimation(loadingText: "Loading posts...", isLoading: true)
                    }
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
