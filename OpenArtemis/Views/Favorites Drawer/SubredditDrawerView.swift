//
//  SubredditDrawerView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/2/23.
//

import SwiftUI
import CoreData
import CachedImage

struct SubredditDrawerView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var coordinator: NavCoordinator
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name)
    ]) var localFavorites: FetchedResults<LocalSubreddit>
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.multiName)
    ]) var localMultis: FetchedResults<LocalMulti>
    
    @State private var subredditName = ""
    @State private var showSaveSubredditDialog = false
    
    @State private var multiName = ""
    @State private var multiImageURL = ""
    @State private var showSaveMultiDialog = false
    
    @State private var availableIndexArr: [String] = []
    
    @State private var editMode = false
    
    let appTheme: AppThemeSettings
    let textSizePreference: TextSizePreference
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ThemedList(appTheme: appTheme, textSizePreference: textSizePreference) {
                    Section(header: Text("Defaults")) {
                        DefaultFavoritesView(localFavorites: localFavorites)
                    }
                    
                    if !localMultis.isEmpty {
                        Section(header: Text("Multis")) {
                            ForEach(localMultis) { multi in
                                if let navMultiName = multi.multiName {
                                    let computedName = concatenateFavsForMulti(multiName: navMultiName)
                                    
                                    DefaultSubredditRowView(title: navMultiName, iconURL: multi.imageURL,
                                                            iconColor: getColorFromInputString(computedName), editMode: editMode,
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
                    
                    Group {
                        let pinnedFavs = localFavorites.filter { $0.pinned }
                        if !pinnedFavs.isEmpty {
                            Section(header: Text("Pinned")) {
                                ForEach(pinnedFavs
                                    .sorted { $0.name ?? "" < $1.name ?? "" }
                                ) { subreddit in
                                    if let subredditName = subreddit.name {
                                        SubredditRowView(
                                            subredditName: subredditName,
                                            pinned: subreddit.pinned,
                                            editMode: editMode,
                                            removeFromSubredditFavorites: {
                                                removeFromSubredditFavorites(subredditName: subreddit.name ?? "")
                                            }, togglePinned: {
                                                togglePinned(subredditName: subreddit.name ?? "")
                                            }, managedObjectContext: managedObjectContext,
                                            localMultis: localMultis
                                        )
                                    }
                                }
                            }
                        }
                    }
                    
                    ForEach(availableIndexArr, id: \.self) { letter in
                        Section(header: Text(letter).id(letter)) {
                            ForEach(localFavorites
                                .filter { subreddit in
                                    if let subName = subreddit.name {
                                        let firstCharacter = subName.first
                                        let startsWithNumber = firstCharacter?.isNumber ?? false
                                        return ((startsWithNumber && letter == "#") || (firstCharacter?.isLetter == true && subName.uppercased().prefix(1) == letter)) && !subreddit.pinned
                                    }
                                    
                                    return false
                                }
                            ) { subreddit in
                                if let subredditName = subreddit.name {
                                    SubredditRowView(
                                        subredditName: subredditName,
                                        pinned: subreddit.pinned,
                                        editMode: editMode,
                                        removeFromSubredditFavorites: {
                                            removeFromSubredditFavorites(subredditName: subreddit.name ?? "")
                                        }, togglePinned: {
                                            togglePinned(subredditName: subreddit.name ?? "")
                                        }, managedObjectContext: managedObjectContext,
                                        localMultis: localMultis
                                    )
                                }
                            }
                        }
                    }
                }
                .refreshable{
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
        }
        .navigationBarItems(
            leading: HStack {
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
        )

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
    
    // manage favorites
    private func removeFromSubredditFavorites(subredditName: String) {
        withAnimation {
            SubredditUtils.shared.removeFromSubredditFavorites(managedObjectContext: managedObjectContext, subredditName: subredditName)
        }
        
        visibleSubredditSections()
    }
    
    private func togglePinned(subredditName: String) {
        withAnimation {
            SubredditUtils.shared.togglePinned(managedObjectContext: managedObjectContext, subredditName: subredditName)
        }
        
        visibleSubredditSections()
    }
    
    // manage multis
    private func concatenateFavsForMulti(multiName: String) -> String {
        let multiSubs = SubredditUtils.shared.subsAssociatedWithMulti(managedObjectContext: managedObjectContext, multiName: multiName)
        if !multiSubs.isEmpty {
            return multiSubs.joined(separator: "+")
        }
        
        return ""
    }
}
