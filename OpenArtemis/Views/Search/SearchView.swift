//
//  SearchView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/1/23.
//

import Defaults
import NaturalLanguage
import SwiftUI

struct SearchView: View {
    @EnvironmentObject var coordinator: NavCoordinator
    @EnvironmentObject var trackingParamRemover: TrackingParamRemover
    @Default(.over18) var over18
    @Default(.nlpSearch) var nlpSearch

    @State private var inputText: String = ""
    @State private var searchText: String = ""
    
    @State private var debugTaggedText: [(String, String)] = []
    @State private var debugEscapedText: String = ""
    
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
    
    var body: some View {
        VStack{
            List {
                if inputText != "" {
                    NavigationLink(destination: {
                        // TODO: Implement
                    }) {
                        Label("Subreddits with \"\(inputText)\"", systemImage: "magnifyingglass")
                    }

                    NavigationLink(destination: {
                        // TODO: Implement
                    }) {
                        Label("Posts with \"\(inputText)\"", systemImage: "square.text.square")
                    }

                    NavigationLink(destination: {
                        // TODO: Implement
                    }) {
                        Label("Go to user \"\(inputText)\"", systemImage: "person")
                    }
                    .disabled(true)
                }

                Section {
                    NavigationLink(value: SubredditFeedResponse(subredditName: "random")) {
                        Label("Random Subreddit", systemImage: "shuffle")
                    }
                }

                
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $inputText)
            .onSubmit(of: .search) {
                performSearch()
            }
            .onChange(of: inputText) { text in
                if nlpSearch && checkIfEnglish(text){
                    searchText = generateSearchStringFromNLQuery(text)
                } else {
                    searchText = text
                }
                
            }
            .animation(.default, value: inputText)
            .onChange(of: searchType) { _, _ in
                clearFeed()
            }

        }
        
        if inputText != "" && nlpSearch{
            VStack{
            Text("Input Text: \(inputText)")
            Text("Escaped Text: \(debugEscapedText)")
            Text("Tagged Text: \(debugTaggedText.map { "\($0.0) - \($0.1)" }.joined(separator: ", "))")
            Text("Search Query: \(searchText)")
            }
            .opacity(0.5)
            .font(.caption)
        }
    }

    private func generateSearchStringFromNLQuery(_ text: String) -> String{

        var literalText = ""
        var processableText: [(String, String)] = []

        let regex = try! NSRegularExpression(pattern: "(“|\"|')(.*)('|\"|”)")
        let matches = regex.matches(in: text, range: NSRange(text.startIndex ..< text.endIndex, in: text))

        for match in matches {
            if let range = Range(match.range, in: text) {
                literalText += text[range]
            }
        }

        let remainingText = regex.stringByReplacingMatches(in: text, range: NSRange(text.startIndex..., in: text), withTemplate: "")
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        let options: NLTagger.Options = [.omitWhitespace, .joinNames]
        tagger.string = remainingText

        tagger.enumerateTags(in: remainingText.startIndex ..< remainingText.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            if let tag = tag?.rawValue {
                processableText.append((String(remainingText[tokenRange]), tag))
            }
            return true
        }

        let searchParams = processText(processableText, remainingText)
        debugEscapedText = literalText
        let searchText =  "\(literalText) \(searchParams)"
        // if nothing can be interpreted fall back to the text
        return searchText == "" ? text : searchText
        
    }

    private func processText(_ taggedText: [(String, String)], _ normalText: String) -> String {
        var searchParamsString = ""

        let urlRegex = try! NSRegularExpression(pattern: "[\\/\\/\\:a-zA-Z0-9]*\\.[A-Za-z0-9]*")
        let urlMatches = urlRegex.matches(in: normalText, range: NSRange(normalText.startIndex ..< normalText.endIndex, in: normalText))

        for match in urlMatches {
            if let range = Range(match.range, in: normalText) {
                searchParamsString += "url:\(normalText[range]) "
            }
        }
        
        debugTaggedText = taggedText
        for word in taggedText {
            // in subreddit
            if word.0.lowercased() == "in" && word.1 == "Preposition" {
                // Find the first Noun after "in" that is not "sub" or "subreddit"
                var currentIndex = getIndexAfter(taggedText, word)
                
                while let index = currentIndex {
                    let currentWord = taggedText[index].0.lowercased()
                    
                    if currentWord == "sub" || currentWord == "subreddit" {
                        // Skip "sub" and "subreddit" words
                        currentIndex = getIndexAfter(taggedText, taggedText[index])
                    } else if taggedText[index].1 == "Noun" {
                        // Found the first Noun after "in" that is not "sub" or "subreddit"
                        let noun = taggedText[index].0
                        searchParamsString += "subreddit:\(noun) "
                        break
                    } else {
                        // Move to the next word
                        currentIndex = getIndexAfter(taggedText, taggedText[index])
                    }
                } else {
                    LoadingView(loadingText: "Loading search...", isLoading: true)
                }
            }


            if word.0.lowercased() == "author" && word.1 == "Noun" {
                if let nextIndex = getIndexAfter(taggedText, word) {
                    let nextWord = taggedText[nextIndex].0
                    searchParamsString += "author:\(nextWord) "
                }
            }
            
            if word.0.lowercased() == "by" && word.1 == "Preposition" {
                if let nextIndex = getIndexAfter(taggedText, word) {
                    let nextWord = taggedText[nextIndex].0
                    searchParamsString += "author:\(nextWord) "
                }
            }
            
            if word.0.lowercased() == "flair" && word.1 == "Noun" {
                if let nextIndex = getIndexAfter(taggedText, word) {
                    let nextWord = taggedText[nextIndex].0
                searchParamsString += "flair:\(nextWord) "
                }
            }
            
        }
        
        return searchParamsString
        
    }
    
    private func getIndexAfter(_ arr: [(String, String)], _ str: (String, String)) -> Int? {
        guard let index = arr.firstIndex(where: { $0 == str}) else { return nil}
        
        let nextIndex = index + 1
        if nextIndex < arr.count {
            return nextIndex
        } else {
            return nil // Return nil if the next index is out of bounds
        }
    }

    enum SearchFilters {
        case author
        case flair
        case selff
        case selftext
        case site
        case subreddit
        case title
        case url
    }

    private func checkIfEnglish(_ string: String) -> Bool {
        // Create a language recognizer.
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(string)

        // Identify the dominant language.
        if let language = recognizer.dominantLanguage {
            return language.rawValue == "en"
        } else {
            print("Language not recognized")
        }
        return false
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
            case let .success(results):
                DispatchQueue.main.async {
                    searchResults = results
                }
            case let .failure(error):
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

struct FilterView: View {
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
