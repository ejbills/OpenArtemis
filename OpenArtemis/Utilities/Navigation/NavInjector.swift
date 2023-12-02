//
//  NavInjector.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/30/23.
//

import Foundation
import SwiftUI

struct HandleDeepLinksDisplay: ViewModifier {
    func body(content: Content) -> some View {
        content
            // MARK: App routing
            .navigationDestination(for: SubredditFeedResponse.self) { response in
                SubredditFeedView(subredditName: response.subredditName)
                    
            }
            .navigationDestination(for: PostResponse.self) { response in
                Text(response.post.title)
                    
            }
        
            .navigationDestination(for: SafariResponse.self) { response in
//                SafariHelper.openSafariView(withURL: response.url)
                
//                EmptyView()
//                    .onAppear {
//                        SafariHelper.openSafariView(withURL: response.url)
//                    }
            }
    }
}

//struct HandleDeepLinkResolution: ViewModifier {
//    let navigationPath: Binding<NavigationPath>
//
//    func body(content: Content) -> some View {
//        content
//            .environment(\.openURL, OpenURLAction(handler: handleIncomingURL))
//    }
//
//    @MainActor
//    func handleIncomingURL(_ url: URL) -> OpenURLAction.Result {
//        guard url.scheme == "calipso-for-squabbles" else {
//            return .systemAction
//        }
//        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
//            print("Invalid URL")
//            return .discarded
//        }
//
////        if let action = components.host, action == "embed" {
////            if let taggedUsername = components.queryItems?.first(where: { $0.name == "name" })?.value {
////                navigationPath.wrappedValue.append(ProfileResponse(username: taggedUsername))
////            } else if let taggedCommunity = components.queryItems?.first(where: { $0.name == "community" })?.value {
////                navigationPath.wrappedValue.append(FeedResponse(community: taggedCommunity))
////            } else if let taggedPost = components.queryItems?.first(where: { $0.name == "postURL" })?.value {
////                fetchPost(postURL: taggedPost) { result in
////                    switch result {
////                    case .success(let fetchedPost):
////                        navigationPath.wrappedValue.append(PostResponse(post: fetchedPost))
////                    case .failure(let error):
////                        // Handle the error if the fetch fails
////                        print("Fetch error:", error.localizedDescription)
////                        navigationPath.wrappedValue.append(ErrorPostResponse(error: error.localizedDescription))
////                    }
////                }
////            }
////        }
//        return .handled
//    }
//}

extension View {
    func handleDeepLinkViews() -> some View {
        modifier(HandleDeepLinksDisplay())
    }
    
//    func handleDeepLinkResolution(navigationPath: Binding<NavigationPath>) -> some View {
//        modifier(HandleDeepLinkResolution(navigationPath: navigationPath))
//    }
}
