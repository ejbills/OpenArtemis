//
//  Post Utils.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/28/23.
//

import Foundation
import CoreData
import Defaults
import SwiftUI

struct Post: Equatable, Hashable, Codable {
    let id: String
    let subreddit: String
    let title: String
    let author: String
    let votes: String
    let mediaURL: PrivateURL
    let commentsURL: String
    
    let type: String
    
    // If post media has a thumbnail...
    let thumbnailURL: String?
    
    // Ensure that PrivateURL also conforms to Codable
    struct PrivateURL: Codable {
        let originalURL: String
        let privateURL: String
    }
    
    // Conform to Codable
    enum CodingKeys: String, CodingKey {
        case id, subreddit, title, author, votes, mediaURL, commentsURL, type, thumbnailURL
    }

    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Don't do drugs kids
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(subreddit)
        hasher.combine(title)
        hasher.combine(author)
        hasher.combine(votes)
        hasher.combine(commentsURL)
        hasher.combine(mediaURL.originalURL)
        hasher.combine(mediaURL.privateURL)
        hasher.combine(type)
        hasher.combine(thumbnailURL)
    }
}


class PostUtils {
    
    /// Converts a `SavedPost` entity to a tuple containing the saved timestamp and a corresponding `Post`.
    ///
    /// - Parameters:
    ///   - post: The `SavedPost` entity to convert.
    /// - Returns: A tuple containing the saved timestamp and the corresponding `Post`.
    func savedPostToPost(_ post: SavedPost) -> (Date?, Post) {
        return (
            post.savedTimestamp,
            Post(
                id: post.id ?? "",
                subreddit: post.subreddit ?? "",
                title: post.title ?? "",
                author: post.author ?? "",
                votes: post.votes ?? "",
                mediaURL: Post.PrivateURL(originalURL: post.mediaURL ?? "", privateURL: post.mediaURL ?? ""),
                commentsURL: post.commentsURL ?? "",
                type: post.type ?? "",
                thumbnailURL: post.thumbnailURL ?? ""
            )
        )
    }

    /// Toggles the saved status of a `Post`.
    ///
    /// - Parameters:
    ///   - post: The `Post` to toggle.
    ///   - savedPosts: The fetched results containing saved posts.
    func toggleSaved(post: Post, savedPosts: FetchedResults<SavedPost>) -> Bool {
        let isPostSaved = savedPosts.contains { $0.id == post.id }
        if isPostSaved {
            removeSavedPost(id: post.id, savedPosts: savedPosts)
            return false
        } else {
            savePost(post: post)
            return true
        }
    }

    /// Saves a `Post` entity.
    ///
    /// - Parameter post: The `Post` to save.
    private func savePost(post: Post) {
        @Default(.redirectToPrivateSites) var privULR
        let managedObjectContext = PersistenceController.shared.container.viewContext
        let tempPost = SavedPost(context: managedObjectContext)
        tempPost.author = post.author
        tempPost.subreddit = post.subreddit
        tempPost.commentsURL = post.commentsURL
        tempPost.id = post.id
        tempPost.mediaURL = privULR ? post.mediaURL.privateURL : post.mediaURL.originalURL
        tempPost.thumbnailURL = post.thumbnailURL
        tempPost.title = post.title
        tempPost.type = post.type
        tempPost.votes = post.votes
        tempPost.savedTimestamp = Date()

        withAnimation {
            PersistenceController.shared.save()
        }
    }

    /// Removes a saved `Post` entity.
    ///
    /// - Parameters:
    ///   - id: The identifier of the `Post` to remove.
    ///   - savedPosts: The fetched results containing saved posts.
    private func removeSavedPost(id: String, savedPosts: FetchedResults<SavedPost>) {
        let managedObjectContext = PersistenceController.shared.container.viewContext
        let matchingPost = savedPosts.filter { $0.id == id }
        for post in matchingPost {
            managedObjectContext.delete(post)
        }

        withAnimation {
            PersistenceController.shared.save()
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
        } else if mediaURL.hasSuffix(".gif") || mediaURL.hasSuffix(".gifv") {
            return "gif"
        } else if mediaURL.contains("v.redd.it") || mediaURL.hasSuffix(".mp4") {
            return "video"
        } else {
            return "article"
        }
    }
}
