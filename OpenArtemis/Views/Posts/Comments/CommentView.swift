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
        HStack(spacing: 4) {
            if comment.depth > 0 {
                Rectangle()
                    .fill(commentIndentationColor(forDepth: comment.depth))
                    .frame(width: 2)
            }
            
            if !comment.isCollapsed {
                VStack(alignment: .leading) {
                    HStack {
                        DetailTagView(icon: "person", data: comment.author)
                        DetailTagView(icon: "arrow.up", data: comment.score)
                        DetailTagView(icon: "timer", data: TimeFormatUtil().formatTimeAgo(fromUTCString: comment.time))
                    }
                    
                    Text(comment.body)
                }
            } else {
                HStack {
                    DetailTagView(icon: "person", data: comment.author)
                    DetailTagView(icon: "arrow.up", data: comment.score)
                    DetailTagView(icon: "timer", data: TimeFormatUtil().formatTimeAgo(fromUTCString: comment.time))
                }
            }
            
            Spacer()
        }
        .padding(8)
    }
}
