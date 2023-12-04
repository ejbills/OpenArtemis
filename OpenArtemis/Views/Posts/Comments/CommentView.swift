//
//  CommentView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/3/23.
//

import SwiftUI

struct CommentView: View {
    var comment: Comment

    var body: some View {
        VStack(alignment: .leading) {
            Text("Author: \(comment.author)")
                .font(.headline)
            
            Text("Body: \(comment.body)")
                .font(.body)
                .lineLimit(nil)
            
            Text("Depth: \(comment.depth)")
                .font(.footnote)
        }
        .padding()
    }
}
