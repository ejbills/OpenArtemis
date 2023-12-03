//
//  NavPayloads.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/30/23.
//

import Foundation
import SwiftUI

// MARK: App routing

struct SubredditFeedResponse: Hashable {
    var subredditName: String
    var titleOverride: String? = nil
    func hash(into hasher: inout Hasher) {
        hasher.combine(subredditName)
    }
}

struct PostResponse: Hashable {
    var post: Post
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(post)
    }
}

//struct ErrorPostResponse: Hashable {
//    var error: String
//    
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(error)
//    }
//}

//struct MoreCommentsResponse: Hashable {
//    var comment: Reply
//    var postAuthor: String
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(comment)
//        hasher.combine(postAuthor)
//    }
//}
//
//struct ProfileResponse: Hashable {
//    var username: String
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(username)
//    }
//}
//
//struct ModeratorListResponse: Hashable {
//    var communities: [Community]
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(communities)
//    }
//}

// MARK: Outside app routing

struct SafariResponse: Hashable {
    var url: URL
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}
