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

    init(comment: Comment, numberOfChildren: Int, postAuthor: String? = nil, appTheme: AppThemeSettings) {
        self.comment = comment
        self.numberOfChildren = numberOfChildren
        self.postAuthor = postAuthor
        self.appTheme = appTheme
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
                
                VStack(alignment: .leading) {
                    HStack(spacing: 4) {
                        DetailTagView(icon: "person", data: comment.author.isEmpty ? "*[deleted]*" : comment.author, appTheme: appTheme)
                            .onTapGesture {
                                coordinator.path.append(ProfileResponse(username: comment.author))
                            }
                            .foregroundColor(
                                commentAuthorColor // assign accent color if comment author is also post author
                            )

                        DetailTagView(icon: "timer", data: TimeFormatUtil().formatTimeAgo(fromUTCString: comment.time), appTheme: appTheme)
                        
                        Spacer()
                        DetailTagView(icon: "arrow.up", data: Int(comment.score)?.roundedWithAbbreviations ?? "[score hidden]", appTheme: appTheme)
                        
                        if comment.isRootCollapsed {
                            DetailTagView(icon: "chevron.down", data: "\(numberOfChildren)", appTheme: appTheme)
                        }
                    }
                    .foregroundStyle(appTheme.tagBackground ? .primary : .secondary)
                    
                    if !comment.isRootCollapsed {
                        Markdown(comment.body.isEmpty ? "*[deleted]*" : comment.body)
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
