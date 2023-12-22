//
//  CommentView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/3/23.
//

import SwiftUI
import MarkdownUI
import Defaults

struct CommentView: View {
    var comment: Comment
    var numberOfChildren: Int
    let appTheme: AppThemeSettings
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
                        DetailTagView(icon: "person", data: comment.author, appTheme: appTheme)
                        DetailTagView(icon: "timer", data: TimeFormatUtil().formatTimeAgo(fromUTCString: comment.time), appTheme: appTheme)
                        
                        Spacer()
                        DetailTagView(icon: "arrow.up", data: Int(comment.score)?.roundedWithAbbreviations ?? "[score hidden]", appTheme: appTheme)
                        
                        if comment.isRootCollapsed {
                            DetailTagView(icon: "chevron.down", data: "\(numberOfChildren)", appTheme: appTheme)
                        }
                    }
                    .foregroundStyle(appTheme.tagBackground ? .primary : .secondary)
                    
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
        .themedBackground(appTheme: appTheme)
    }
}
