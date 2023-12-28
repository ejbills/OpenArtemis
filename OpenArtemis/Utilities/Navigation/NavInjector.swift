//
//  NavInjector.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/30/23.
//

import Foundation
import SwiftUI
import Defaults

struct HandleDeepLinksDisplay: ViewModifier {
    @Default(.appTheme) var appTheme
    
    func body(content: Content) -> some View {
        content
        // MARK: App routing
            .navigationDestination(for: SubredditFeedResponse.self) { response in
                if response.subredditName == "Saved" {
                    SavedView(appTheme: appTheme)
                } else {
                    SubredditFeedView(subredditName: response.subredditName, titleOverride: response.titleOverride, appTheme: appTheme)
                }
                
            }
            .navigationDestination(for: ProfileResponse.self) { response in
                ProfileView(username: response.username, appTheme: appTheme)
            }
            .navigationDestination(for: PostResponse.self) { response in
                PostPageView(post: response.post, appTheme: appTheme)
            }
    }
}

struct HandleDeepLinkResolution: ViewModifier {
    @EnvironmentObject var coordinator: NavCoordinator
    
    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction(handler: handleIncomingURL))
    }

    @MainActor
    func handleIncomingURL(_ url: URL) -> OpenURLAction.Result {
        guard URLComponents(url: url, resolvingAgainstBaseURL: true) != nil else {
            print("Invalid URL")
            return .discarded
        }

        if url.absoluteString.starts(with: "openartemis://") {
            let urlStringWithoutScheme = url.absoluteString.replacingOccurrences(of: "openartemis://", with: "")
            
            if urlStringWithoutScheme.hasPrefix("/u/") {
                if let username = urlStringWithoutScheme.split(separator: "/u/").last {
                    // handle profile viewing...
                    coordinator.path.append(ProfileResponse(username: String(username)))
                }
            } else if urlStringWithoutScheme.hasPrefix("/r/") {
                if let subreddit = urlStringWithoutScheme.split(separator: "/r/").last {
                    // handle subreddit viewing...
                    coordinator.path.append(SubredditFeedResponse(subredditName: String(subreddit)))
                }
            } else {
                // handle regular link display in an in-app browser
                let safariURL = URL(string: "https://" + urlStringWithoutScheme)
                
                if let safariURL = safariURL {
                    SafariHelper.openSafariView(withURL: safariURL)
                }
            }
        } else {
            // handle link normally if its not an internal (deep) link
            SafariHelper.openSafariView(withURL: url)
        }

        return .handled
    }
}

extension View {
    func handleDeepLinkViews() -> some View {
        modifier(HandleDeepLinksDisplay())
    }
    
    func handleDeepLinkResolution() -> some View {
        modifier(HandleDeepLinkResolution())
    }
}
