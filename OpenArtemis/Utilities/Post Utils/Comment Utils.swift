//
//  Comment Utils.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/3/23.
//

import Foundation
import SwiftUI

struct Comment: Equatable{
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
}
