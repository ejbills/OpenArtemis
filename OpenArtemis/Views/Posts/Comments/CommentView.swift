//
//  CommentView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/3/23.
//

import SwiftUI
import RichText

struct CommentView: View {
    var comment: Comment

    var body: some View {
        VStack(alignment: .leading) {
            Text("Author: \(comment.author)")
                .font(.headline)
            
            RichText(html: comment.body)
//            Text("Body: \(comment.body)")
//                .font(.body)
//                .lineLimit(nil)
            
            Text("Depth: \(comment.depth)")
                .font(.footnote)
        }
        .padding()
    }
}
