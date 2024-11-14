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
    @State private var mixedMediaIDs = LimitedSet<String>(maxLength: 300)
    @State private var isLoading: Bool = false
    
    @State private var selectedSortOption: PostSortOption = .relevance
    @State private var selectedTopOption: TopPostListingSortOption = .all
    
    @FetchRequest(
        entity: SavedPost.entity(),
        sortDescriptors: []
    ) var savedPosts: FetchedResults<SavedPost>
    
    @FetchRequest(
        entity: ReadPost.entity(),
        sortDescriptors: []
    ) var readPosts: FetchedResults<ReadPost>
    
    let appTheme: AppThemeSettings
    let textSizePreference: TextSizePreference
    
    var body: some View {
        VStack(spacing: 0) {
            let isSubredditSearch = searchType == "sr"
            ThemedList(appTheme: appTheme, textSizePreference: textSizePreference, stripStyling: shouldApplyStripStyling(isSubredditSearch)) {
                if !isLoading {
                    if shouldShowFilterView(isSubredditSearch) {
                        SortOptionView(selectedSortOption: $selectedSortOption, selectedTopOption: $selectedTopOption, performSearch: performSearch)
                    }
                    
                    if shouldShowSortingHints(isSubredditSearch) {
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
                        ContentListView(
                            content: $searchResults,
                            readPosts: readPosts,
                            savedPosts: savedPosts,
                            appTheme: appTheme,
                            textSizePreference: textSizePreference,
                            preventDivider: isSubredditSearch
                        )
                    }
                } else {
                    LoadingView(loadingText: "Loading search...", isLoading: true, textSizePreference: textSizePreference)
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
        clearFeed()
        isLoading = true
        
        RedditScraper.search(query: inputText, searchType: searchType, sortBy: selectedSortOption, topSortBy: selectedTopOption,
                             trackingParamRemover: trackingParamRemover, over18: over18) { result in
            defer {
                isLoading = false
            }
            
            switch result {
            case .success(let newMedia):
                for media in newMedia {
                    let mediaID = MiscUtils.extractMediaId(from: media)
                    if !mixedMediaIDs.contains(mediaID) {
                        searchResults.append(media)
                        mixedMediaIDs.insert(mediaID)
                    }
                }
            case .failure(let error):
                print("Search error: \(error)")
            }
        }
    }
    
    private func clearFeed() {
        withAnimation(.smooth) {
            searchResults.removeAll()
            mixedMediaIDs.removeAll()
            isLoading = false
        }
    }
    
    // MARK: Determining what should be visible - helper methods
    private func shouldApplyStripStyling(_ subredditSearch: Bool) -> Bool {
        return ((!subredditSearch && !searchResults.isEmpty) || (!inputText.isEmpty && !subredditSearch)) && !isLoading
    }

    private func shouldShowFilterView(_ subredditSearch: Bool) -> Bool {
        return !subredditSearch && (!inputText.isEmpty || !searchResults.isEmpty)
    }

    private func shouldShowSortingHints(_ subredditSearch: Bool) -> Bool {
        return searchResults.isEmpty && (inputText.isEmpty || subredditSearch)
    }
}

struct SortOptionView: View {
    @Binding var selectedSortOption: PostSortOption
    @Binding var selectedTopOption: TopPostListingSortOption
    var performSearch: () -> Void
    
    var body: some View {
        HStack {
            Picker("Sort By", selection: $selectedSortOption) {
                ForEach(PostSortOption.allCases) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            }
            .padding(.horizontal, 4)
            .onChange(of: selectedSortOption) { _, _ in
                performSearch()
            }
            
            Picker("Time", selection: $selectedTopOption) {
                ForEach(TopPostListingSortOption.allCases) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            }
            .padding(.horizontal, 4)
            .onChange(of: selectedTopOption) { _, _ in
                performSearch()
            }
            
            Spacer()
        }
        
        Divider()
    }
}
