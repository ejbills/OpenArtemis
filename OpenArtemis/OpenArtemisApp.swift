//
//  OpenArtemisApp.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/1/23.
//

import SwiftUI

@main
struct OpenArtemisApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStackWrapper(tabCoordinator: NavCoordinator()) {
                    SubredditFeedView(subredditName: "all")
                        .handleDeepLinkViews()
                }
                .tabItem {
                    Label("Home", systemImage: "homekit")
                }
                
                NavigationStackWrapper(tabCoordinator: NavCoordinator()) {
                    SearchView()
                        .handleDeepLinkViews()
                }
                .tabItem {
                    Label("Search", systemImage: "text.magnifyingglass")
                }
            }
        }
    }
}
