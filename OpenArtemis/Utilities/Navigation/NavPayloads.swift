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
