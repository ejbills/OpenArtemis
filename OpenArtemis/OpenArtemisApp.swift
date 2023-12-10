//
//  OpenArtemisApp.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/1/23.
//

import SwiftUI
import Defaults

@main
struct OpenArtemisApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Default(.preferredThemeMode) var preferredThemeMode
    
    //TrackingParamRemover as Environment Object so it loads / downloads the tracking params list only once and doesnt unload / load them all the time
    @ObservedObject private var trackingParamRemover = TrackingParamRemover()
    
    // Scene phase tracks when the app goes to the background
    @Environment(\.scenePhase) var scenePhase
    
    // this is the shared context controller for our CoreData module
    let persistenceController = PersistenceController.shared
        
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStackWrapper(tabCoordinator: NavCoordinator()) {
                    SubredditDrawerView()
                        .handleDeepLinkViews()
                }
                .tabItem {
                    Label("Feed", systemImage: "doc.richtext")
                }
                
                NavigationStackWrapper(tabCoordinator: NavCoordinator()) {
                    SearchView()
                        .handleDeepLinkViews()
                }
                .tabItem {
                    Label("Search", systemImage: "text.magnifyingglass")
                }
                
                NavigationStackWrapper(tabCoordinator: NavCoordinator()){
                    PrivacyTab()
                }
                .tabItem {
                    Label("Privacy", systemImage: "shield.lefthalf.filled")
                }
                
                NavigationStackWrapper(tabCoordinator: NavCoordinator(), content: {
                    SettingsView()
                        .handleDeepLinkViews()
                })
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            }
            .accentColor(Color.artemisAccent)
            .preferredColorScheme(preferredThemeMode.id == 0 ? nil : preferredThemeMode.id == 1 ? .light : .dark)
        }
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
        .environment(trackingParamRemover)
        .onChange(of: scenePhase) {
            // Always save to coredata when app moves to background
            persistenceController.save()
        }
    }
}
