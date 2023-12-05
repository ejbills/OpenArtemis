//
//  Comment Utils.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/3/23.
//

import Foundation
import SwiftUI

struct Comment {
    let id: String
    let parentID: String?
    var childID: String?
    let author: String
    let score: String // since comments show score as "X votes" rather than just the int
    let time: String
    let body: String
    let depth: Int
    var isCollapsed: Bool
    var isRootCollapsed: Bool
    
    
}

func getNumberOfDescendants(for comment: Comment, in comments: [Comment]) -> Int {
    return countDescendants(for: comment, in: comments)
}

private func countDescendants(for comment: Comment, in comments: [Comment]) -> Int {
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

public func commentIndentationColor(forDepth depth: Int) -> Color {
    // Choose a color based on depth
    let colorIndex = depth % colorPalette.count
    return colorPalette[colorIndex]
}
