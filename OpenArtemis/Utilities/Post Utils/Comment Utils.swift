//
//  Comment Utils.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/3/23.
//

import Foundation
import SwiftUI

struct Comment: Equatable, Codable, Hashable{
    let id: String
    let parentID: String?
    let author: String
    let score: String // since comments show score as "X votes" rather than just the int
    let time: String
    let body: String
    let depth: Int
    let stickied: Bool
    var isCollapsed: Bool
    var isRootCollapsed: Bool
}

class CommentUtils {
    // comment section helpers
    struct AnchorsKey: PreferenceKey {
        // Each key is a comment id. The corresponding value is the
        // .center anchor of that row.
        typealias Value = [String: Anchor<CGPoint>]
        
        static var defaultValue: Value { [:] }
        
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value.merge(nextValue()) { $1 }
        }
    }
    
    func topCommentRow(of anchors: CommentUtils.AnchorsKey.Value, in proxy: GeometryProxy) -> String? {
        var yBest = CGFloat.infinity
        var answer: String?
        for (row, anchor) in anchors {
            let y = proxy[anchor].y
            guard y >= 0, y < yBest else { continue }
            answer = row
            yBest = y
        }
        return answer
    }
    
    func getNumberOfDescendants(for comment: Comment, in comments: [Comment]) -> Int {
        return countDescendants(for: comment, in: comments)
    }
    
    func countDescendants(for comment: Comment, in comments: [Comment]) -> Int {
        // Filter comments that have the current comment as their parent
        let children = comments.filter { $0.parentID == comment.id }
        
        // Initialize the count with the number of immediate children
        var descendantCount = children.count
        
        // Recursively count descendants for each child
        for child in children {
            descendantCount += countDescendants(for: child, in: comments)
        }
        
        // Return the total count of descendants
        return descendantCount
    }
    
    func commentIndentationColor(forDepth depth: Int) -> Color {
        // Choose a color based on depth
        let colorIndex = depth % colorPalette.count
        return colorPalette[colorIndex]
    }
    
    /// Converts a `SavedComment` entity to a triple containing the saved timestamp, a corresponding `Comment`, and the post link.
    ///
    /// - Parameter comment: The `SavedComment` entity to convert.
    /// - Returns: A triple containing the saved timestamp, the corresponding `Comment`, and the post link.
    func savedCommentToComment(_ comment: SavedComment) -> (Date?, Comment, String) {
        return (
            comment.savedTimestamp,
            Comment(
                id: comment.id ?? "",
                parentID: comment.parentID,
                author: comment.author ?? "",
                score: comment.score ?? "",
                time: comment.time ?? "",
                body: comment.body ?? "",
                depth: Int(comment.depth),
                stickied: comment.stickied,
                isCollapsed: comment.isCollapsed,
                isRootCollapsed: comment.isRootCollapsed
            ),
            comment.postLink ?? ""
        )
    }

    /// Toggles the saved status of a `Comment`.
    ///
    /// - Parameters:
    ///   - comment: The `Comment` to toggle.
    ///   - post: The associated `Post` of the comment.
    ///   - savedComments: The fetched results containing saved comments.
    func toggleSaved(comment: Comment, post: Post, savedComments: FetchedResults<SavedComment>) -> Bool{
        let isCommentSaved = savedComments.contains { $0.id == comment.id }
        
        if isCommentSaved {
            removeSavedComment(id: comment.id, savedComments: savedComments)
            return false
        } else {
            saveComment(comment: comment, post: post)
            return true
        }
    }

    /// Saves a `Comment` entity.
    ///
    /// - Parameters:
    ///   - comment: The `Comment` to save.
    ///   - post: The associated `Post` of the comment.
    private func saveComment(comment: Comment, post: Post) {
        let managedObjectContext = PersistenceController.shared.container.viewContext
        let tempComment = SavedComment(context: managedObjectContext)
        tempComment.id = comment.id
        tempComment.body = comment.body
        tempComment.depth = Int32(comment.depth)
        tempComment.author = comment.author
        tempComment.isCollapsed = comment.isRootCollapsed
        tempComment.isRootCollapsed = comment.isRootCollapsed
        tempComment.parentID = comment.parentID
        tempComment.score = comment.score
        tempComment.stickied = comment.stickied
        tempComment.time = comment.time
        tempComment.savedTimestamp = Date()
        tempComment.postLink = post.commentsURL
        
        withAnimation {
            PersistenceController.shared.save()
        }
    }

    /// Removes a saved `Comment` entity.
    ///
    /// - Parameters:
    ///   - id: The identifier of the `Comment` to remove.
    ///   - savedComments: The fetched results containing saved comments.
    private func removeSavedComment(id: String, savedComments: FetchedResults<SavedComment>) {
        let managedObjectContext = PersistenceController.shared.container.viewContext
        let matchingComment = savedComments.filter { $0.id == id }
        for comment in matchingComment {
            managedObjectContext.delete(comment)
        }
        
        withAnimation {
            PersistenceController.shared.save()
        }
    }

}
