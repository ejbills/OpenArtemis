//
//  CommentView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/3/23.
//

import SwiftUI

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
                    HStack {
                        DetailTagView(icon: "person", data: comment.author)
                        DetailTagView(icon: "timer", data: TimeFormatUtil().formatTimeAgo(fromUTCString: comment.time))
                        
                        Spacer()
                        DetailTagView(icon: "arrow.up", data: Int(comment.score)?.roundedWithAbbreviations ?? "[score hidden]")
                        
                        if comment.isRootCollapsed {
                            HStack{
                                Text("\(numberOfChildren)")
                                    .foregroundStyle(.white)
                                    .padding(1)
                                    .padding(.horizontal, 2.5)
                                    .background(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)).foregroundStyle(Color(uiColor: UIColor.systemGray4)))
                                Image(systemName: "chevron.down")
                                    .opacity(0.3)
                            }
                        }
                        
                    }
                    
                    if !comment.isRootCollapsed {
                        Text(comment.body)
                    }
                }
            }            
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity)
        }
        .contentShape(Rectangle())
        .background(Color(uiColor: UIColor.systemBackground))
    }
}
