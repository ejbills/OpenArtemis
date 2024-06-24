//
//  TapHighlighter.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 4/4/24.
//

import SwiftUI

struct TapHighlighter: ButtonStyle {
    let cornerRadius: CGSize
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .overlay(
                RoundedRectangle(cornerSize: cornerRadius)
                    .contrast(configuration.isPressed ? 3.0 : 0.0)
                    .foregroundColor(configuration.isPressed ? Color.gray.opacity(0.15) : Color.clear)
            )
    }
}
