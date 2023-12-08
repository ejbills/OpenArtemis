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
    static let shared = PostUtils()

    private init() {}

    func savedPostToPost(context: NSManagedObjectContext, _ post: SavedPost) -> (Date?, Post) {
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

    func toggleSaved(context: NSManagedObjectContext, post: Post) -> Bool {
        let savedPosts = fetchSavedPosts(context: context)
        let isPostSaved = savedPosts.contains { $0.id == post.id }
        if isPostSaved {
            removeSavedPost(context: context, id: post.id)
            return false
        } else {
            savePost(context: context, post: post)
            return true
        }
    }

    func savePost(context: NSManagedObjectContext, post: Post) {
        @Default(.redirectToPrivateSites) var privULR
        let tempPost = SavedPost(context: context)
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
            do {
                try context.save()
            } catch {
                print("Error saving post: \(error)")
            }
        }
    }

    func removeSavedPost(context: NSManagedObjectContext, id: String) {
        let matchingPost = fetchSavedPost(context: context, id: id)
        for post in matchingPost {
            context.delete(post)
        }

        withAnimation {
            do {
                try context.save()
            } catch {
                print("Error removing saved post: \(error)")
            }
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

    func fetchSavedPosts(context: NSManagedObjectContext) -> [SavedPost] {
        do {
            return try context.fetch(SavedPost.fetchRequest())
        } catch {
            print("Error fetching saved posts: \(error)")
            return []
        }
    }

    func fetchSavedPost(context: NSManagedObjectContext, id: String) -> [SavedPost] {
        let request: NSFetchRequest<SavedPost> = SavedPost.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching saved post: \(error)")
            return []
        }
    }
}
