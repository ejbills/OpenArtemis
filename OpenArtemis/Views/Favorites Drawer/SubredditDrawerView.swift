//
//  SubredditDrawerView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/2/23.
//

import SwiftUI
import CoreData
import CachedImage
import Defaults

struct SubredditDrawerView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @EnvironmentObject private var coordinator: NavCoordinator
    
    // Fetch requests to retrieve local favorites and multis from Core Data
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) private var localFavorites: FetchedResults<LocalSubreddit>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.multiName)]) private var localMultis: FetchedResults<LocalMulti>
    
    // State variables
    @State private var subredditName = ""
    @State private var showSaveSubredditDialog = false
    @State private var multiName = ""
    @State private var multiImageURL = ""
    @State private var showSaveMultiDialog = false
    @State private var availableIndexArr: [String] = []
    @State private var editMode = false
    @State private var hasAppeared: Bool = false
    @Default(.defaultLaunchFeed) private var defaultLaunchFeed
    @State private var exitDefault: Bool = false
    @Default(.hideFavorites) private var hideFavorites
    
    // External parameters
    let appTheme: AppThemeSettings
    let textSizePreference: TextSizePreference
    
    var body: some View {
        ZStack {
            // Show the default subreddit feed based on the conditions
            if defaultLaunchFeed != "favList" && !exitDefault {
                getSubredditFeedView()
                    .zIndex(1)
            }
            
            VStack {
                ScrollViewReader { proxy in
                    ThemedList(appTheme: appTheme, textSizePreference: textSizePreference) {
                        Section(header: Text("Defaults")) {
                            DefaultFavoritesView(localFavorites: localFavorites, concatFavSubs: concatenateFavoriteSubs)
                        }
                        
                        // Show multis section if there are any
                        if !localMultis.isEmpty {
                            Section(header: Text("Multis")) {
                                ForEach(localMultis) { multi in
                                    if let navMultiName = multi.multiName {
                                        let computedName = concatenateFavsForMulti(multiName: navMultiName)
                                        
                                        DefaultSubredditRowView(title: navMultiName,
                                                                iconURL: multi.imageURL,
                                                                iconColor: getColorFromInputString(computedName),
                                                                editMode: editMode,
                                                                removeMulti: {
                                            SubredditUtils.shared.removeFromMultis(managedObjectContext: managedObjectContext, multiName: navMultiName)
                                        })
                                        .background(
                                            NavigationLink(value: SubredditFeedResponse(subredditName: computedName, titleOverride: navMultiName)) {
                                                EmptyView()
                                            }
                                                .disabled(editMode || computedName.isEmpty)
                                                .opacity(0)
                                        )
                                    }
                                }
                            }
                        }
                        
                        // Group pinned and unpinned favorites separately
                        Group {
                            let pinnedFavs = localFavorites.filter { $0.pinned }
                            if !pinnedFavs.isEmpty {
                                Section(header: Text("Pinned")) {
                                    ForEach(pinnedFavs.sorted { $0.name ?? "" < $1.name ?? "" }) { subreddit in
                                        if let subredditName = subreddit.name {
                                            SubredditRowView(
                                                subredditName: subredditName,
                                                iconURL: subreddit.iconURL,
                                                pinned: subreddit.pinned,
                                                editMode: editMode,
                                                removeFromSubredditFavorites: {
                                                    removeFromSubredditFavorites(subredditName: subreddit.name ?? "")
                                                },
                                                togglePinned: {
                                                    togglePinned(subredditName: subreddit.name ?? "")
                                                },
                                                fetchIcon: {
                                                    fetchIcon(subredditName: subreddit.name ?? "")
                                                },
                                                managedObjectContext: managedObjectContext,
                                                localMultis: localMultis
                                            )
                                        }
                                    }
                                }
                            }
                        }
                        
                        if !localFavorites.isEmpty {
                            // Show unpinned favorites categorized by the first letter
                            if !hideFavorites {
                                ForEach(availableIndexArr, id: \.self) { letter in
                                    Section(header: Text(letter).id(letter)) {
                                        ForEach(localFavorites.filter { subreddit in
                                            if let subName = subreddit.name {
                                                let firstCharacter = subName.first
                                                let startsWithNumber = firstCharacter?.isNumber ?? false
                                                return ((startsWithNumber && letter == "#") || (firstCharacter?.isLetter == true && subName.uppercased().prefix(1) == letter)) && !subreddit.pinned
                                            }
                                            
                                            return false
                                        }) { subreddit in
                                            if let subredditName = subreddit.name {
                                                SubredditRowView(
                                                    subredditName: subredditName,
                                                    iconURL: subreddit.iconURL,
                                                    pinned: subreddit.pinned,
                                                    editMode: editMode,
                                                    removeFromSubredditFavorites: {
                                                        removeFromSubredditFavorites(subredditName: subreddit.name ?? "")
                                                    },
                                                    togglePinned: {
                                                        togglePinned(subredditName: subreddit.name ?? "")
                                                    },
                                                    fetchIcon: {
                                                        fetchIcon(subredditName: subreddit.name ?? "")
                                                    },
                                                    managedObjectContext: managedObjectContext,
                                                    localMultis: localMultis
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                            
                            Section("Options") {
                                CollapsibleSectionHeader(
                                    title: "Favorites",
                                    isOn: $hideFavorites,
                                    onLabel: "Hide",
                                    offLabel: "Show",
                                    textSizePreference: textSizePreference)
                            }
                        }
                    }
                    .refreshable {
                        visibleSubredditSections()
                    }
                    .onAppear {
                        visibleSubredditSections()
                    }
                    .overlay(
                        HStack {
                            Spacer()
                            SectionIndexTitlesView(proxy: proxy, availChars: availableIndexArr, textSizePreference: textSizePreference)
                                .padding(.trailing, 4)
                        }
                    )
                }
            }
            
            // Alerts for adding subreddit and multi
            .alert("Add Subreddit", isPresented: $showSaveSubredditDialog) {
                TextField("Subreddit name", text: $subredditName)
                
                Button("Save") {
                    withAnimation {
                        SubredditUtils.shared.saveToSubredditFavorites(managedObjectContext: managedObjectContext, name: subredditName)
                    }
                    
                    visibleSubredditSections()
                    showSaveSubredditDialog = false
                }
                
                Button("Cancel") {
                    showSaveSubredditDialog = false
                }
            } message: {
                Text("Enter the subreddit name you wish to add to your favorites.")
            }
            .alert("Add Multireddit", isPresented: $showSaveMultiDialog) {
                TextField("Name", text: $multiName)
                TextField("Thumbnail image URL (optional)", text: $multiImageURL)
                
                Button("Save") {
                    SubredditUtils.shared.saveToMultis(managedObjectContext: managedObjectContext, name: multiName, imageURL: multiImageURL)
                    showSaveMultiDialog = false
                }
                
                Button("Cancel") {
                    showSaveMultiDialog = false
                }
            } message: {
                Text("Enter the multi name and thumbnail image URL (optional) you wish to add to your favorites.")
            }
        }
        
        // Set the navigation title based on the condition
        .if(!(defaultLaunchFeed != "favList" && !exitDefault)) { view in
            view.navigationTitle("Favorites")
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Show different toolbar items based on the condition
            if defaultLaunchFeed != "favList" && !exitDefault {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        withAnimation(.snappy) {
                            exitDefault = true
                        }
                    }) {
                        Text("Exit")
                    }
                }
            } else {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button(action: {
                            subredditName = ""
                            showSaveSubredditDialog = true
                        }) {
                            Label("Add subreddit", systemImage: "plus")
                        }
                        
                        Button(action: {
                            multiName = ""
                            multiImageURL = ""
                            showSaveMultiDialog = true
                        }) {
                            Label("Add multireddit", systemImage: "square.grid.2x2")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        withAnimation(.smooth) {
                            editMode.toggle()
                        }
                    }) {
                        Text(editMode ? "Done" : "Edit")
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    /// Concatenates the names of all favorite subreddits into a single string separated by '+'.
    private func concatenateFavoriteSubs() -> String {
        let favoriteSubs = localFavorites.compactMap { $0.name }
        return favoriteSubs.joined(separator: "+")
    }
    
    /// Determines the visible subreddit sections and updates the `availableIndexArr`.
    private func visibleSubredditSections() {
        let unpinnedFavorites = localFavorites.filter { !$0.pinned }
        let unpinnedNames = unpinnedFavorites.compactMap { $0.name }
        let lowercaseUnpinnedNames = unpinnedNames.map { $0.lowercased() }
        
        availableIndexArr = drawerChars.filter { letter in
            if letter == "#" {
                return lowercaseUnpinnedNames.contains { name in
                    if let firstCharacter = name.first {
                        return firstCharacter.isNumber
                    }
                    return false
                }
            } else {
                return lowercaseUnpinnedNames.contains { name in
                    let firstLetter = name.prefix(1)
                    return firstLetter.lowercased() == letter.lowercased()
                }
            }
        }
    }
    
    /// Handles rendering the default launch feed
    private func getSubredditFeedView() -> SubredditFeedView {
        switch defaultLaunchFeed {
        case "all":
            return SubredditFeedView(subredditName:
                                        // something here?
                                     defaultLaunchFeed, titleOverride: nil, appTheme: appTheme, textSizePreference: textSizePreference)
        case "popular":
            return SubredditFeedView(subredditName: defaultLaunchFeed.capitalized, titleOverride: nil, appTheme: appTheme, textSizePreference: textSizePreference)
        case "home":
            if !localFavorites.isEmpty {
                return SubredditFeedView(subredditName: concatenateFavoriteSubs(), titleOverride: defaultLaunchFeed.capitalized, appTheme: appTheme, textSizePreference: textSizePreference)
            } else {
                return SubredditFeedView(subredditName: "OpenArtemisApp", titleOverride: "Empty home feed :(", appTheme: appTheme, textSizePreference: textSizePreference)
            }
        default:
            let multiName = defaultLaunchFeed
            let computedName = concatenateFavsForMulti(multiName: multiName)
            return SubredditFeedView(subredditName: computedName, titleOverride: multiName, appTheme: appTheme, textSizePreference: textSizePreference)
        }
    }
    
    // MARK: - Favorite Management
    
    /// Removes the given subreddit name from the subreddit favorites.
    private func removeFromSubredditFavorites(subredditName: String) {
        withAnimation {
            SubredditUtils.shared.removeFromSubredditFavorites(managedObjectContext: managedObjectContext, subredditName: subredditName)
        }
        
        visibleSubredditSections()
    }
    
    /// Toggles the pinned state of the given subreddit name.
    private func togglePinned(subredditName: String) {
        withAnimation {
            SubredditUtils.shared.togglePinned(managedObjectContext: managedObjectContext, subredditName: subredditName)
        }
        
        visibleSubredditSections()
    }
    
    /// Parses subreddit icon and saves to coredata.
    private func fetchIcon(subredditName: String) {
        withAnimation {
            SubredditUtils.shared.fetchIconURL(managedObjectContext: managedObjectContext, subredditName: subredditName)
        }
    }
    
    // MARK: - Multi Management
    
    /// Concatenates the subreddit names associated with the given multi name into a single string separated by '+'.
    private func concatenateFavsForMulti(multiName: String) -> String {
        let multiSubs = SubredditUtils.shared.subsAssociatedWithMulti(managedObjectContext: managedObjectContext, multiName: multiName)
        if !multiSubs.isEmpty {
            return multiSubs.joined(separator: "+")
        }
        
        return ""
    }
}
