//
//  Post Utils.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/28/23.
//

import Foundation

struct Post: Equatable, Hashable {
    let id: String
    let subreddit: String
    let title: String
    let author: String
    let score: String
    let mediaURL: PrivateURL
    
    let type: String
    
    // If post media has a thumbnail...
    let thumbnailURL: String?
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }
    
    //Don't do drugs kids
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(subreddit)
        hasher.combine(title)
        hasher.combine(author)
        hasher.combine(score)
        hasher.combine(mediaURL.originalURL)
        hasher.combine(mediaURL.privateURL)
        hasher.combine(type)
        hasher.combine(thumbnailURL)
    }
}

func determinePostType(mediaURL: String) -> String {
    let mediaURL = mediaURL.lowercased()
    
    if mediaURL.contains("/r/") && mediaURL.contains("/comments/") {
        return "text"
    } else if mediaURL.contains("reddit.com/gallery/") {
        return "gallery"
    } else if mediaURL.hasSuffix(".png") || mediaURL.hasSuffix(".jpg") || mediaURL.hasSuffix(".jpeg") {
        return "image"
    } else if mediaURL.hasSuffix(".gif") || mediaURL.hasSuffix(".gifv") || mediaURL.hasSuffix(".mp4") {
        return "video"
    } else if mediaURL.contains("v.redd.it") {
        return "video"
    } else {
        return "article"
    }
}
