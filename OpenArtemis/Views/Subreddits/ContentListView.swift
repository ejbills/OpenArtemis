//
//  ContentListView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 1/2/24.
//

import SwiftUI

struct ContentListView: View {
    @Binding var content: [MixedMedia]
    var readPosts: FetchedResults<ReadPost>?
    var savedPosts: FetchedResults<SavedPost>?
    var savedComments: FetchedResults<SavedComment>?
    var appTheme: AppThemeSettings
    var onListElementAppearance: ((MixedMedia) -> Void)?
    var preventRead: Bool = false
    var preventDivider: Bool = false
    
    var body: some View {
        ForEach(content, id: \.self) { result in
            var isRead: Bool {
                if preventRead {
                    return false
                }
                
                switch result {
                case .post(let post, _):
                    return readPosts?.contains(where: { $0.readPostId == post.id }) ?? false
                default:
                    return false
                }
            }
            
            var isSaved: Bool {
                switch result {
                case .post(let post, _):
                    return savedPosts?.contains { $0.id == post.id } ?? false
                case .comment(let comment, _):
                    return savedComments?.contains { $0.id == comment.id } ?? false
                default:
                    return false
                }
            }

            MixedContentView(content: result, isRead: isRead, appTheme: appTheme)
                .savedIndicator(isSaved)
                .onAppear {
                    onListElementAppearance?(result)
                }
            if !preventDivider {
                DividerView(frameHeight: 10, appTheme: appTheme)
            }
        }
    }
}
