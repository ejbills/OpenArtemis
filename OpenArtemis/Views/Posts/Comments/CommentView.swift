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
    @EnvironmentObject var coordinator: NavCoordinator
    
    let comment: Comment
    let numberOfChildren: Int
    let postAuthor: String?
    let appTheme: AppThemeSettings
    let textSizePreference: TextSizePreference

    init(comment: Comment, numberOfChildren: Int, postAuthor: String? = nil, appTheme: AppThemeSettings, textSizePreference: TextSizePreference) {
        self.comment = comment
        self.numberOfChildren = numberOfChildren
        self.postAuthor = postAuthor
        self.appTheme = appTheme
        self.textSizePreference = textSizePreference
    }
    
    var body: some View {
        var commentAuthorColor: Color {
            if let author = postAuthor, comment.author == author {
                return Color.accentColor
            } else {
                return appTheme.tagBackground ? .primary : .secondary
            }
        }
        
        Group {
            HStack(spacing: 4) {
                if comment.depth > 0 {
                    Rectangle()
                        .fill(CommentUtils.shared.commentIndentationColor(forDepth: comment.depth))
                        .frame(width: 2)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 4) {
                        DetailTagView(icon: "person", data: comment.author.isEmpty ? "[deleted]" : comment.author, appTheme: appTheme, textSizePreference: textSizePreference) {
                            coordinator.path.append(ProfileResponse(username: comment.author))
                        }
                        .foregroundColor(
                            commentAuthorColor // assign accent color if comment author is also post author
                        )

                        DetailTagView(icon: "timer", data: TimeFormatUtil().formatTimeAgo(fromUTCString: comment.time), appTheme: appTheme, textSizePreference: textSizePreference)
                        
                        Spacer()
                        DetailTagView(icon: "arrow.up", data: Int(comment.score)?.roundedWithAbbreviations ?? "[score hidden]", appTheme: appTheme, textSizePreference: textSizePreference)
                        
                        if comment.isRootCollapsed {
                            DetailTagView(icon: "chevron.down", data: "\(numberOfChildren)", appTheme: appTheme, textSizePreference: textSizePreference)
                        }
                    }
                    .foregroundStyle(appTheme.tagBackground ? .primary : .secondary)
                    
                    if !comment.isRootCollapsed {
                        Markdown(comment.body.isEmpty ? "[deleted]" : comment.body)
                            .markdownTheme(.artemisMarkdown(fontSize: textSizePreference.bodyFontSize))
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
            }
        }
        .contentShape(Rectangle())
        .themedBackground(appTheme: appTheme)
    }
}
