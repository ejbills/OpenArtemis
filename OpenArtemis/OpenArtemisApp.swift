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
    @Default(.appTheme) var appTheme
    
    //TrackingParamRemover as Environment Object so it loads / downloads the tracking params list only once and doesnt unload / load them all the time
    @ObservedObject private var trackingParamRemover = TrackingParamRemover()
    
    // Scene phase tracks when the app goes to the background
    @Environment(\.scenePhase) var scenePhase
    // this is the shared context controller for our CoreData module
    let persistenceController = PersistenceController.shared
    @Default(.showingOOBE) var showingOOBE
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStackWrapper(tabCoordinator: NavCoordinator()) {
                    SubredditDrawerView(appTheme: appTheme)                        
                }
                .tabItem {
                    Label("Feed", systemImage: "doc.richtext")
                }
                
                NavigationStackWrapper(tabCoordinator: NavCoordinator()) {
                    SearchView(appTheme: appTheme)
                }
                .tabItem {
                    Label("Search", systemImage: "text.magnifyingglass")
                }
                
                NavigationStackWrapper(tabCoordinator: NavCoordinator()){
                    PrivacyTab(appTheme: appTheme)
                }
                .tabItem {
                    Label("Privacy", systemImage: "shield.lefthalf.filled")
                }
                
                NavigationStackWrapper(tabCoordinator: NavCoordinator(), content: {
                    SettingsView()
                })
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            }
            .accentColor(Color.artemisAccent)
            .preferredColorScheme(appTheme.preferredThemeMode.id == 0 ? nil : appTheme.preferredThemeMode.id == 1 ? .light : .dark)
            .sheet(isPresented: $showingOOBE){
                OnboardingView(appTheme: appTheme)
            }
        }
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
        .environment(trackingParamRemover)
        .onChange(of: scenePhase) {
            // Always save to coredata when app moves to background
            persistenceController.save()
        }
    }
}
