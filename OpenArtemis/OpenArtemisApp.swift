//
//  OpenArtemisApp.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/1/23.
//

import SwiftUI
import Defaults
import AlertToast

@main
struct OpenArtemisApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Default(.appTheme) var appTheme
    @Default(.textSizePreference) var textSizePreference
    
    //TrackingParamRemover as Environment Object so it loads / downloads the tracking params list only once and doesnt unload / load them all the time
    @ObservedObject private var trackingParamRemover = TrackingParamRemover()
    
    // Scene phase tracks when the app goes to the background
    @Environment(\.scenePhase) var scenePhase
    // this is the shared context controller for our CoreData module
    let persistenceController = PersistenceController.shared
    @Default(.showingOOBE) var showingOOBE
    var body: some Scene {
        WindowGroup {
            ContentView(appTheme: appTheme, textSizePreference: textSizePreference)
                .accentColor(Color.artemisAccent)
                .preferredColorScheme(appTheme.preferredThemeMode.id == 0 ? nil : appTheme.preferredThemeMode.id == 1 ? .light : .dark)
                .sheet(isPresented: $showingOOBE){
                    OnboardingView(appTheme: appTheme, textSizePreference: textSizePreference)
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

struct ContentView: View {
    var appTheme = AppThemeSettings()
    let textSizePreference: TextSizePreference
    
    @State private var showNavBackButton: Bool = false
    
    var body: some View {
        TabView {
            // Feed Tab
            getNavigationView {
                SubredditDrawerView(appTheme: appTheme, textSizePreference: textSizePreference)
            }
            .tabItem {
                Label("Feed", systemImage: "doc.richtext")
            }
            
            // Search Tab
            getNavigationView {
                SearchView(appTheme: appTheme, textSizePreference: textSizePreference)
            }
            .tabItem {
                Label("Search", systemImage: "text.magnifyingglass")
            }
            
            // Privacy Tab
            getNavigationView(forceNonSplitStack: true) {
                PrivacyTab(appTheme: appTheme, textSizePreference: textSizePreference)
            }
            .tabItem {
                Label("Privacy", systemImage: "shield.lefthalf.filled")
            }
            
            // Settings Tab
            getNavigationView(forceNonSplitStack: true) {
                SettingsView(textSizePreference: textSizePreference)
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
        .overlay {
            if GlobalLoadingManager.shared.loading {
                AlertToast(type: .loading)
            }
            
            if GlobalLoadingManager.shared.failed {
                AlertToast(type: .error(.red))
            }
        }
        
        // MARK: nav back button rendering
        .onChange(of: GlobalNavForwardManager.shared.toastButton) { _, state in
            showNavBackButton = state
        }
        .toast(isPresenting: $showNavBackButton, duration: 3, tapToDismiss: true, alert: {
            AlertToast(displayMode: .hud, type: .systemImage("arrow.uturn.right", .artemisAccent), title: "Go back")
        }, onTap: {
            GlobalNavForwardManager.shared.returnPrevNav()
        }, completion: {
            GlobalNavForwardManager.shared.toastButton = false
        })
    }
    
    @ViewBuilder
    private func getNavigationView<Content: View>(forceNonSplitStack: Bool = false, @ViewBuilder content: @escaping () -> Content) -> some View {
        let nav = NavCoordinator()
        
        if UIDevice.current.userInterfaceIdiom == .phone || forceNonSplitStack {
            NavigationStackWrapper(tabCoordinator: nav, content: content)
        } else {
            NavigationSplitViewWrapper(tabCoordinator: nav, sidebar: content) {
                NothingHereView(textSizePreference: textSizePreference)
            }
        }
    }
    
}
