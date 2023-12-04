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
    let author: String
    let score: String // since comments show score as "X votes" rather than just the int
    let time: String
    let body: String
    let depth: Int
}

public func commentIndentationColor(forDepth depth: Int) -> Color {
    // Choose a color based on depth
    let colors: [Color] = [.red, .orange, .green, .blue, .purple, .pink]
    let colorIndex = depth % colors.count
    return colors[colorIndex]
}
