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
                ThemedList {
                    Section(header: Text("Defaults")) {
                        DefaultSubredditRowView(title: "Home", iconSystemName: "house.fill", iconColor: .artemisAccent)
                            .background(
                                NavigationLink(value: SubredditFeedResponse(subredditName: concatenateFavoriteSubs(), titleOverride: "Home")){
                                    EmptyView()
                                }
                                    .opacity(0)
                            )
                            .disabledView(disabled: localFavorites.isEmpty)
                            
                        
                        DefaultSubredditRowView(title: "All", iconSystemName: "star.fill", iconColor: colorPalette[0])
                            .background(
                                // highlights button on tap (cant be modifier or inside child view)
                                NavigationLink(value: SubredditFeedResponse(subredditName: "All")) {
                                    EmptyView()
                                }
                                .opacity(0)
                            )
                        
                        DefaultSubredditRowView(title: "Popular", iconSystemName: "lightbulb.fill", iconColor: colorPalette[2])
                            .background(
                                NavigationLink(value: SubredditFeedResponse(subredditName: "Popular")) {
                                    EmptyView()
                                }
                                .opacity(0)
                            )
                        
                        DefaultSubredditRowView(title: "Saved", iconSystemName: "bookmark.fill", iconColor: colorPalette[4])
                            .background(
                                NavigationLink(value: SubredditFeedResponse(subredditName: "Saved")) {
                                    EmptyView()
                                }
                                .opacity(0)
                            )
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
                    .refreshable{
                        visibleSubredditSections()
                    }
                .scrollIndicators(.hidden)
                .onAppear {
                    visibleSubredditSections()
                }
            
                .overlay(
                    HStack {
                        Spacer()
                        SectionIndexTitlesView(proxy: proxy, availChars: availableIndexArr)
                            .padding(.trailing, 4)
                    }
                )
            }
        }
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(action: {
                    withAnimation(.smooth) {
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
                withAnimation {
                    SubredditUtils.shared.saveToSubredditFavorites(managedObjectContext: managedObjectContext, name: subredditName)
                }
                
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
                    if let firstCharacter = name.first {
                        return firstCharacter.isNumber
                    }
                    
                    return false
                }
            } else {
                return lowercaseLocalFavorites.contains { name in
                    let firstLetter = name.prefix(1)
                    return firstLetter.lowercased() == letter.lowercased()
                }
            }
        }
    }
    
    // manage favorites
    private func removeFromSubredditFavorites(subredditName: String) {
        withAnimation {
            SubredditUtils.shared.removeFromSubredditFavorites(managedObjectContext: managedObjectContext, subredditName: subredditName)
        }
        
        visibleSubredditSections()
    }
}
