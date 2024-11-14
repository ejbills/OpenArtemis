//
//  CommentThemeView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 4/5/24.
//

import SwiftUI
import Defaults

struct CommentThemeView: View {
    @Default(.commentColorPalette) var commentColorPalette
    let appTheme: AppThemeSettings
    let textSizePreference: TextSizePreference
    
    @State private var refreshId = UUID()
    
    private let previewComments = [
        Comment(id: "1", parentID: nil, author: "meow", score: "42", time: "2024-04-10T12:00:00Z",
               body: "This is a top-level comment", depth: 0, stickied: false, directURL: "",
               isCollapsed: false, isRootCollapsed: false),
        Comment(id: "2", parentID: "1", author: "woof", score: "28", time: "2024-04-10T12:05:00Z",
               body: "This is a reply", depth: 1, stickied: false, directURL: "",
               isCollapsed: false, isRootCollapsed: false),
    ]
    
    var body: some View {
        ThemedList(appTheme: appTheme, textSizePreference: textSizePreference) {
            Section {
                Text("Choose a color palette for comment indentation. The colors distinguish different comment depths in threads.")
                    .font(textSizePreference.caption)
                    .foregroundColor(.secondary)
            }
            
            Section("Preview") {
                VStack(spacing: 0) {
                    ForEach(previewComments, id: \.id) { comment in
                        CommentView(
                            comment: comment,
                            numberOfChildren: 0,
                            postAuthor: "User1",
                            appTheme: appTheme,
                            textSizePreference: textSizePreference
                        )
                    }
                }
                .padding(.vertical, 4)
                .id(refreshId)
            }
            
            Section("Color Palettes") {
                ForEach(ColorPalettes.allPalettes, id: \.self) { palette in
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            commentColorPalette = palette
                            refreshId = UUID() // Force preview to refresh with new color
                        }
                    } label: {
                        HStack {
                            ForEach(0..<palette.count, id: \.self) { index in
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(palette[index])
                                    .frame(height: 40)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.vertical, 8)
                        .opacity(commentColorPalette[0].toHex() == palette[0].toHex() ? 0.1 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: commentColorPalette)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("Comment Theme")
        .navigationBarTitleDisplayMode(.inline)
    }
}
