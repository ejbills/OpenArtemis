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
    @Default(.textSizePreference) var textSizePreference
    
    func body(content: Content) -> some View {
        content
        // MARK: App routing
            .navigationDestination(for: SubredditFeedResponse.self) { response in
                if response.subredditName == "Saved" {
                    SavedView(appTheme: appTheme, textSizePreference: textSizePreference)
                } else {
                    SubredditFeedView(subredditName: response.subredditName, titleOverride: response.titleOverride, appTheme: appTheme, textSizePreference: textSizePreference)
                }
            }
            .navigationDestination(for: ProfileResponse.self) { response in
                ProfileView(username: response.username, appTheme: appTheme, textSizePreference: textSizePreference)
            }
            .navigationDestination(for: PostResponse.self) { response in
                PostPageView(post: response.post, commentsURLOverride: response.commentsURLOverride, appTheme: appTheme, textSizePreference: textSizePreference)
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
                    coordinator.navToAndStore(forData: NavigationPayload.profile(ProfileResponse(username: String(username))))
                }
            } else if urlStringWithoutScheme.hasPrefix("/r/") {
                if let subreddit = urlStringWithoutScheme.split(separator: "/r/").last {
                    // handle subreddit viewing...
                    coordinator.navToAndStore(forData: NavigationPayload.subredditFeed(SubredditFeedResponse(subredditName: String(subreddit))))
                }
            } else {
                if urlStringWithoutScheme.contains("reddit.com") && urlStringWithoutScheme.contains("/comments/") {
                    GlobalLoadingManager.shared.setLoading(toState: true)
                    
                    let convertedUrl = "https://" + MiscUtils.convertToOldRedditLink(normalLink: urlStringWithoutScheme)
                    
                    // It's a Reddit post URL, scrape the post
                    RedditScraper.scrapePostFromURL(url: convertedUrl, trackingParamRemover: nil) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let post):
                                coordinator.navToAndStore(forData: NavigationPayload.post(PostResponse(post: post)))
                                GlobalLoadingManager.shared.setLoading(toState: false)
                            case .failure(let error):
                                print("Failed to scrape Reddit post: \(error)")
                                GlobalLoadingManager.shared.setLoading(toState: false)
                            }
                        }
                    }
                } else {
                    // handle regular link display in an in-app browser
                    let safariURL = URL(string: "https://" + urlStringWithoutScheme)
                    
                    if let safariURL {
                        SafariHelper.openSafariView(withURL: safariURL)
                    }
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
