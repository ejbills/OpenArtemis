//
//  DefaultSubredditRowView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/2/23.
//

import SwiftUI
import CachedImage

struct DefaultSubredditRowView: View {
    var title: String
    var iconSystemName: String?
    var iconURL: String?
    var iconColor: Color
    var editMode: Bool?
    var removeMulti: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            if let editMode, editMode, let removeMulti = removeMulti {
                Button(action: {
                    removeMulti()
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 20))
                }
            }
            
            Label(
                title: { Text(title) },
                icon: {
                    Image(systemName: iconSystemName ?? "poweroutlet.type.m.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color.white)
                        .padding(6)
                        .frame(maxWidth: 30, maxHeight: 30)
                        .background{
                            RoundedRectangle(cornerSize: CGSize(width: 7, height: 7))
                                .foregroundStyle(iconColor)
                                .frame(width: 30, height: 30)
                        }
                }
            )
            .labelStyle(DefaultLabelStyle())
            .foregroundColor(.primary)
        }
        .if(iconURL != nil) { content in
            content.listRowBackground(
                GeometryReader { geometry in
                    if let iconURL = iconURL, let url = URL(string: iconURL) {
                        CachedImage(
                            url: url,
                            content: { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .opacity(0.3)
                                    .clipped()
                            },
                            placeholder: {
                                Color.clear
                            }
                        )
                    }
                }
            )
        }
    }
}
