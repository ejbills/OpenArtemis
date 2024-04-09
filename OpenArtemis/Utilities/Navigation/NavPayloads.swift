//
//  NavPayloads.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/30/23.
//

import Foundation
import SwiftUI

// MARK: Common data type for nav payload

enum NavigationPayload: Hashable {
    case subredditFeed(SubredditFeedResponse)
    case profile(ProfileResponse)
    case post(PostResponse)
    
    // Hashable conformance for the enum
    func hash(into hasher: inout Hasher) {
        switch self {
        case .subredditFeed(let response):
            hasher.combine(response)
        case .profile(let response):
            hasher.combine(response)
        case .post(let response):
            hasher.combine(response)
        }
    }
    
    // Define how to check for equality between two NavigationPayloads
    static func == (lhs: NavigationPayload, rhs: NavigationPayload) -> Bool {
        switch (lhs, rhs) {
        case let (.subredditFeed(lhsResponse), .subredditFeed(rhsResponse)):
            return lhsResponse == rhsResponse
        case let (.profile(lhsResponse), .profile(rhsResponse)):
            return lhsResponse == rhsResponse
        case let (.post(lhsResponse), .post(rhsResponse)):
            return lhsResponse == rhsResponse
        default:
            return false
        }
    }
}


// MARK: App routing

struct SubredditFeedResponse: Hashable {
    var subredditName: String
    var titleOverride: String? = nil
}

struct ProfileResponse: Hashable {
    var username: String
}

struct PostResponse: Hashable {
    var post: Post
    var commentsURLOverride: String? = nil
}
