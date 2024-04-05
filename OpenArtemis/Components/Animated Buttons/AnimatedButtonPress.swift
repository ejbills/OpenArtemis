//
//  AnimatedButtonPress.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 4/4/24.
//

import SwiftUI

struct AnimatedButtonPress<Content: View>: View {
    let action: (() -> Void)?
    let content: Content
    let cornerRadius: CGSize?
    
    // Using @ViewBuilder allows the initialization with any SwiftUI View
    init(@ViewBuilder content: () -> Content, onTap action: (() -> Void)? = nil, cornerRadius: CGSize? = nil) {
        self.content = content()
        self.action = action
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        Button(action: {
            action?()
        }, label: {
            content
        })
        .buttonStyle(TapHighlighter(cornerRadius: cornerRadius ?? CGSize(width: 0.0, height: 0.0)))
    }
}
