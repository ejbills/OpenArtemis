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
    
    var body: some View {
        ThemedList(appTheme: appTheme, textSizePreference: textSizePreference) {
            ForEach(ColorPalettes.allPalettes, id: \.self) { palette in
                Button {
                    withAnimation {
                        commentColorPalette = palette
                    }
                } label: {
                    ColorPaletteRowView(palette: palette)
                        .opacity(commentColorPalette[0].toHex() == palette[0].toHex() ? 0.1 : 1.0)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Comment Indentation Theme")
    }
}

struct ColorPaletteRowView: View {
    let palette: [Color]

    var body: some View {
        HStack {
            ForEach(0..<palette.count, id: \.self) { index in
                palette[index]
                    .frame(width: 50, height: 50)
                    .cornerRadius(5)
            }
        }
        .padding(.vertical, 5)
    }
}
