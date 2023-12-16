//
//  CommentView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/3/23.
//

import SwiftUI
import MarkdownUI

struct CommentView: View {    
    var comment: Comment
    var numberOfChildren: Int
    var body: some View {
        Group {
            HStack(spacing: 4) {
                if comment.depth > 0 {
                    Rectangle()
                        .fill(CommentUtils.shared.commentIndentationColor(forDepth: comment.depth))
                        .frame(width: 2)
                }
                
                VStack(alignment: .leading) {
                    HStack(spacing: 4) {
                        DetailTagView(icon: "person", data: comment.author)
                        DetailTagView(icon: "timer", data: TimeFormatUtil().formatTimeAgo(fromUTCString: comment.time))
                        
                        Spacer()
                        DetailTagView(icon: "arrow.up", data: Int(comment.score)?.roundedWithAbbreviations ?? "[score hidden]")
                        
                        if comment.isRootCollapsed {
                            DetailTagView(icon: "chevron.down", data: "\(numberOfChildren)")
                        }
                        
                    }
                    
                    if !comment.isRootCollapsed {
                        Markdown(comment.body)
                    }
                }
            }            
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity)
        }
        .contentShape(Rectangle())
        .themedBackground()
    }
}
