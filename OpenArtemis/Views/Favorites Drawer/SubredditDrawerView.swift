//
//  SubredditDrawerView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/2/23.
//

import SwiftUI
import CoreData

struct SubredditDrawerView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var coordinator: NavCoordinator
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name)
    ]) var localFavorites: FetchedResults<LocalSubreddit>
    
    @State private var subredditName = ""
    @State private var showSaveDialog = false
    
    @State private var availableIndexArr: [String] = []
    
    @State private var editMode = false
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ZStack {
                    List {
                        Section(header: Text("Defaults")) {
                            
                            DefaultSubredditRowView(title: "Home", iconSystemName: "house.circle", iconColor: .artemisAccent)
                                .background(
                                    NavigationLink(value: SubredditFeedResponse(subredditName: concatenateFavoriteSubs(), titleOverride: "Home")){
                                        EmptyView()
                                    }
                                        .opacity(0)
                                )
                            
                            DefaultSubredditRowView(title: "All", iconSystemName: "star.circle", iconColor: .yellow)
                                .background(
                                    // highlights button on tap (cant be modifier or inside child view)
                                    NavigationLink(value: SubredditFeedResponse(subredditName: "all")) {
                                        EmptyView()
                                    }
                                    .opacity(0)
                                )
                            
                            DefaultSubredditRowView(title: "Popular", iconSystemName: "lightbulb.circle", iconColor: .blue)
                                .background(
                                    NavigationLink(value: SubredditFeedResponse(subredditName: "popular")) {
                                        EmptyView()
                                    }
                                    .opacity(0)
                                )
                            
                            DefaultSubredditRowView(title: "Saved", iconSystemName: "bookmark.circle", iconColor: .green)
                                .background(
                                    NavigationLink(value: SubredditFeedResponse(subredditName: "saved")) {
                                        EmptyView()
                                    }
                                    .opacity(0)
                                )
                                .disabledView(disabled: true)
                        }
                        
                        ForEach(availableIndexArr, id: \.self) { letter in
                            Section(header: Text(letter).id(letter)) {
                                ForEach(localFavorites
                                    .filter { subreddit in
                                        if let subName = subreddit.name {
                                            let firstCharacter = subName.first
                                            let startsWithNumber = firstCharacter?.isNumber ?? false
                                            return (startsWithNumber && letter == "#") || (firstCharacter?.isLetter == true && subName.uppercased().prefix(1) == letter)
                                        }
                                        
                                        return false
                                    }
                                ) { subreddit in
                                    SubredditRowView(
                                        subreddit: subreddit,
                                        editMode: editMode,
                                        removeFromSubredditFavorites: {
                                            removeFromSubredditFavorites(subredditName: subreddit.name ?? "")
                                            visibleSubredditSections()
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .scrollIndicators(.hidden)
                    .onAppear {
                        visibleSubredditSections()
                    }
                    
                    SectionIndexTitlesView(proxy: proxy, availChars: availableIndexArr)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.leading, 8)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                        .padding(.trailing, 4)
                }
            }
        }
        .navigationTitle("Favorites")
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(action: {
                    withAnimation(.snappy) {
                        editMode.toggle()
                    }
                }) {
                    Text( editMode ? "Done" : "Edit" )
                }
            }
            
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    subredditName = ""
                    showSaveDialog = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("Add Subreddit", isPresented: $showSaveDialog) {
            TextField("Subreddit name", text: $subredditName)
            
            Button("Save") {
                saveToSubredditFavorites(name: subredditName)
                visibleSubredditSections()
                showSaveDialog = false
            }
            
            Button("Cancel") {
                showSaveDialog = false
            }
        } message: {
            Text("Enter the subreddit name you wish to add to your favorites.")
        }
    }
    
    private func concatenateFavoriteSubs() -> String {
        let favoriteSubs = localFavorites.compactMap { $0.name }
        return favoriteSubs.joined(separator: "+")
    }

    
    private func visibleSubredditSections() {
        let localFavorites = localFavorites.compactMap { $0.name }
        let lowercaseLocalFavorites = localFavorites.map { $0.lowercased() }
                
        availableIndexArr = drawerChars.filter { letter in
            if letter == "#" {
                return lowercaseLocalFavorites.contains { name in
                    let firstCharacter = name[name.startIndex]
                    return firstCharacter.isNumber
                }
            } else {
                return lowercaseLocalFavorites.contains { name in
                    let firstLetter = name.prefix(1)
                    return firstLetter.lowercased() == letter.lowercased()
                }
            }
        }
    }
    
    private func removeFromSubredditFavorites(subredditName: String) {
        let matchingSubreddits = localFavorites.filter { $0.name == subredditName }

        for subreddit in matchingSubreddits {
            managedObjectContext.delete(subreddit)
        }

        withAnimation(.snappy) {
            PersistenceController.shared.save()
        }
    }
    
     func saveToSubredditFavorites(name: String) {
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                            .replacingOccurrences(of: "^/r/", with: "", options: .regularExpression)
                            .replacingOccurrences(of: "^r/", with: "", options: .regularExpression)

        let tempSubreddit = LocalSubreddit(context: managedObjectContext)
        tempSubreddit.name = cleanedName
        
        withAnimation(.snappy) {
            PersistenceController.shared.save()
        }
    }
}
