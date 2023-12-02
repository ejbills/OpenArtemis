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
        
    @State private var hasPresented = false
    @State private var isShowingDefaultFeed = false
    
    @State private var subredditName = ""
    @State private var showSaveDialog = false
    
    @State private var availableIndexArr: [String] = []
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ZStack {
                    List {
                        Section(header: Text("Defaults")) {
                            Label(
                                title: { Text("All") },
                                icon: {
                                    Image(systemName: "star.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.yellow)
                                }
                            )
                            .labelStyle(DefaultLabelStyle())
                            .foregroundColor(.primary)
                            .background(
                                NavigationLink(value: SubredditFeedResponse(subredditName: "all")) {
                                    EmptyView()
                                }
                                .opacity(0)
                            )
                            
                            Label(
                                title: { Text("Popular") },
                                icon: {
                                    Image(systemName: "lightbulb.min")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.blue)
                                }
                            )
                            .labelStyle(DefaultLabelStyle())
                            .foregroundColor(.primary)
                            .background(
                                NavigationLink(value: SubredditFeedResponse(subredditName: "popular")) {
                                    EmptyView()
                                }
                                .opacity(0)
                            )
                            
                            Label(
                                title: { Text("Saved") },
                                icon: {
                                    Image(systemName: "bookmark")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.green)
                                }
                            )
                            .labelStyle(DefaultLabelStyle())
                            .foregroundColor(.primary)
                            .background(
                                NavigationLink(value: SubredditFeedResponse(subredditName: "saved")) {
                                    EmptyView()
                                }
                                .opacity(0)
                            )
                            .disabledView(isEnabled: false)
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
                                    if let subName = subreddit.name {
                                        HStack {
                                            getColorFromInputString(subName)
                                                .frame(width: 30, height: 30)
                                                .clipShape(Circle())
                                            
                                            VStack(alignment: .leading) {
                                                Text(subName)
                                                Text("Tap to go to r/\(subName)")
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .background(
                                            NavigationLink(value: SubredditFeedResponse(subredditName: subName)) {
                                                EmptyView()
                                            }
                                            .opacity(0)
                                        )
                                    }
                                }
                            }
                        }
                        .onDelete { index in
                            removeFromSubredditFavorites(at: index)
                            visibleSubredditSections()
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
            ToolbarItem(placement: .navigationBarTrailing) {
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
    
    func removeFromSubredditFavorites(at offsets: IndexSet) {
        for index in offsets {
            let subreddit = localFavorites[index]
            managedObjectContext.delete(subreddit)
        }
        
        PersistenceController.shared.save()
    }
    
    func saveToSubredditFavorites(name: String) {
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                            .replacingOccurrences(of: "^/r/", with: "", options: .regularExpression)
                            .replacingOccurrences(of: "^r/", with: "", options: .regularExpression)

        let tempSubreddit = LocalSubreddit(context: managedObjectContext)
        tempSubreddit.name = cleanedName
        
        PersistenceController.shared.save()
    }
}
