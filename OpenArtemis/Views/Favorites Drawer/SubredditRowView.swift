//
//  SubredditRowView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/2/23.
//

import SwiftUI
import CoreData

struct SubredditRowView: View {
    var subredditName: String
    var pinned: Bool = false
    var editMode: Bool = false
    var removeFromSubredditFavorites: (() -> Void)? = nil
    var togglePinned: (() -> Void)? = nil
    var skipSaved: Bool = false
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var localMultis: FetchedResults<LocalMulti>? = nil
    
    @State private var showMultiSelector: Bool = false
    
    var body: some View {
        HStack {
            if editMode, let removeFromFavorites = removeFromSubredditFavorites {
                Button(action: {
                    removeFromFavorites()
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 20))
                }
            }
            
            getColorFromInputString(subredditName)
                .frame(width: 30, height: 30)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(subredditName)
            }
            
            if !skipSaved {
                Spacer()
                Group {
                    if pinned {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color.artemisAccent)
                            .font(.system(size: 20))
                    } else {
                        Image(systemName: "star")
                            .foregroundColor(.gray)
                            .font(.system(size: 20))
                    }
                }
                .onTapGesture {
                    if let togglePinned {
                        togglePinned()
                        HapticManager.shared.confirmationInfo()
                    }
                }
            }
        }
        .background(
            NavigationLink(value: SubredditFeedResponse(subredditName: subredditName)) {
                EmptyView()
            }
                .opacity(0)
                .disabled(editMode)
        )
        .contextMenu {
            if let removeFromFavorites = removeFromSubredditFavorites {
                Button(action: {
                    removeFromFavorites()
                }) {
                    Label("Remove from Favorites", systemImage: "trash")
                        .foregroundColor(.red)
                }
            }
            
            if let managedObjectContext {
                // logic related to either add or remove a subreddit from a multi
                let multiAssociation = SubredditUtils.shared.getMultiFromSub(managedObjectContext: managedObjectContext,
                                                                             subredditName: subredditName)
                // 'multi association' is just what multi a subreddit is assigned to
                
                Button(action: {
                    if let multiAssociation, !multiAssociation.isEmpty {
                        SubredditUtils.shared.toggleMulti(managedObjectContext: managedObjectContext,
                                                          multiName: multiAssociation,
                                                          subredditName: subredditName)
                    } else {
                        showMultiSelector.toggle()
                    }
                    
                    HapticManager.shared.confirmationInfo()
                }) {
                    if let multiAssociation, !multiAssociation.isEmpty {
                        Label("Remove from '\(multiAssociation)'", systemImage: "trash")
                    } else {
                        Label("Add to a multi", systemImage: "plus.app")
                    }
                }
            }
        }
        .sheet(isPresented: $showMultiSelector) {
            if let localMultis {
                NavigationView {
                    List(localMultis) { multi in
                        if let multiName = multi.multiName {
                            Button(action: {
                                if let managedObjectContext {
                                    SubredditUtils.shared.toggleMulti(managedObjectContext: managedObjectContext,
                                                                      multiName: multiName,
                                                                      subredditName: subredditName)
                                    showMultiSelector = false
                                }
                            }) {
                                Text(multiName)
                            }
                        }
                    }
                    .navigationTitle("Select Multi")
                    .navigationBarItems(trailing: Button("Done") {
                        showMultiSelector = false
                    })
                }
            }
        }
    }
}
