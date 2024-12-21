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
    @State private var isShowingSplash = true
    
    @ObservedObject private var trackingParamRemover = TrackingParamRemover()
    
    @Environment(\.scenePhase) var scenePhase
    let persistenceController = PersistenceController.shared
    @Default(.showingOOBE) var showingOOBE
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView(appTheme: appTheme, textSizePreference: textSizePreference)
                    .accentColor(Color.artemisAccent)
                    .preferredColorScheme(appTheme.preferredThemeMode.id == 0 ? nil : appTheme.preferredThemeMode.id == 1 ? .light : .dark)
                    .sheet(isPresented: $showingOOBE) {
                        OnboardingView(appTheme: appTheme, textSizePreference: textSizePreference)
                    }
                
                if isShowingSplash {
                    SplashScreenView(isActive: $isShowingSplash)
                }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environment(trackingParamRemover)
            .onChange(of: scenePhase) {
                persistenceController.save()
            }
        }
    }
}

struct ContentView: View {
    var appTheme = AppThemeSettings()
    let textSizePreference: TextSizePreference
    
    var body: some View {
        TabView {
            // Feed Tab
            getNavigationView(content: {
                SubredditDrawerView(appTheme: appTheme, textSizePreference: textSizePreference)
            }, shouldRespondToGlobalLinking: true)
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
    }
    
    @ViewBuilder
    private func getNavigationView<Content: View>(forceNonSplitStack: Bool = false, @ViewBuilder content: @escaping () -> Content, shouldRespondToGlobalLinking: Bool = false) -> some View {
        let nav = NavCoordinator()
        
        if UIDevice.current.userInterfaceIdiom == .phone || forceNonSplitStack {
            NavigationStackWrapper(tabCoordinator: nav, content: content, shouldRespondToGlobalLinking: shouldRespondToGlobalLinking)
        } else {
            NavigationSplitViewWrapper(tabCoordinator: nav, sidebar: content, detail: {
                NothingHereView(textSizePreference: textSizePreference)
            }, shouldRespondToGlobalLinking: shouldRespondToGlobalLinking)
        }
    }
    
}
