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
    var shouldRespondToGlobalLinking = false
    
    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction(handler: handleIncomingURL))
            .onOpenURL { incomingURL in
                if shouldRespondToGlobalLinking {
                    _ = handleIncomingURL(incomingURL) // silence unused warning
                }
            }
    }
    
    @MainActor
    func handleIncomingURL(_ url: URL) -> OpenURLAction.Result {
        if url.scheme == "openartemis" {
            let urlStringWithoutScheme = url.absoluteString.replacingOccurrences(of: "openartemis://", with: "")
            
            if urlStringWithoutScheme.hasPrefix("/u/") {
                if let username = urlStringWithoutScheme.split(separator: "/").last {
                    // handle profile viewing...
                    coordinator.path.append(ProfileResponse(username: String(username)))
                }
            } else if urlStringWithoutScheme.hasPrefix("/r/") {
                if let subreddit = urlStringWithoutScheme.split(separator: "/").last {
                    // handle subreddit viewing...
                    coordinator.path.append(SubredditFeedResponse(subredditName: String(subreddit)))
                }
            } else {
                handleRedditURL(urlStringWithoutScheme)
            }
        } else if url.scheme == "http" || url.scheme == "https" {
            // handle link normally if it's an external (web) link
            SafariHelper.openSafariView(withURL: url)
        } else {
            // Unsupported URL scheme
            print("Unsupported URL scheme: \(url.scheme ?? "nil")")
            return .discarded
        }
        
        return .handled
    }
    
    private func handleRedditURL(_ urlStringWithoutScheme: String) {
        let cleanedURLString = MiscUtils.convertToOldRedditLink(normalLink: urlStringWithoutScheme)
        let correctedURLString = correctSchemeInURLString(cleanedURLString)
        
        // Ensure URL has a scheme
        let fullURLString = correctedURLString.hasPrefix("http") ? correctedURLString : "https://" + correctedURLString
        
        if let url = URL(string: fullURLString) {
            let pathComponents = url.pathComponents
            
            print(pathComponents)
            
            if pathComponents.count > 1 {
                switch pathComponents[1] {
                case "r":
                    if pathComponents.count > 3 && pathComponents[3] == "comments" {
                        handlePostOrComment(url: url, pathComponents: pathComponents)
                    } else if pathComponents.count > 2 {
                        // handle subreddit viewing...
                        let subreddit = pathComponents[2]
                        coordinator.path.append(SubredditFeedResponse(subredditName: subreddit))
                    }
                case "user", "u":
                    if pathComponents.count > 2 {
                        // handle profile viewing...
                        let username = pathComponents[2]
                        coordinator.path.append(ProfileResponse(username: username))
                    }
                default:
                        SafariHelper.openSafariView(withURL: url)
                }
            } else {
                    SafariHelper.openSafariView(withURL: url)
            }
        }
    }
    
    private func handlePostOrComment(url: URL, pathComponents: [String]) {
        GlobalLoadingManager.shared.setLoading(toState: true)
        
        RedditScraper.scrapePostFromURL(url: url.absoluteString, trackingParamRemover: nil) { result in
            DispatchQueue.main.async {
                handleRedditPostScrapeResult(result, originalURL: url.absoluteString)
            }
        }
    }
    
    private func handleRedditPostScrapeResult(_ result: Result<Post, Error>, originalURL: String) {
        switch result {
        case .success(let post):
            coordinator.path.append(PostResponse(post: post, commentsURLOverride: originalURL))
        case .failure(let error):
            print("Failed to scrape Reddit post: \(error)")
        }
        
        GlobalLoadingManager.shared.setLoading(toState: false)
    }
    
    private func correctSchemeInURLString(_ urlString: String) -> String {
        var correctedURLString = urlString
        if urlString.starts(with: "https//") {
            correctedURLString = urlString.replacingOccurrences(of: "https//", with: "https://")
        } else if urlString.starts(with: "http//") {
            correctedURLString = urlString.replacingOccurrences(of: "http//", with: "http://")
        }
        return correctedURLString
    }
}


extension View {
    func handleDeepLinkViews() -> some View {
        modifier(HandleDeepLinksDisplay())
    }
    
    func handleDeepLinkResolution(shouldRespondToGlobalLinking: Bool = false) -> some View {
        modifier(HandleDeepLinkResolution(shouldRespondToGlobalLinking: shouldRespondToGlobalLinking))
    }
}
