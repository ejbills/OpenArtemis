//
//  SizeModifier.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/1/23.
//

import SwiftUI
import UIKit

struct HeightPreferenceKey : PreferenceKey {
    
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
    
}

struct WidthPreferenceKey : PreferenceKey {
    
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
    
}

struct SizePreferenceKey : PreferenceKey {
    
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
    
}

extension View {
    func readWidth() -> some View {
        background(GeometryReader {
            Color.clear.preference(key: WidthPreferenceKey.self, value: $0.size.width)
        })
    }
    
    func readHeight() -> some View {
        background(GeometryReader {
            Color.clear.preference(key: HeightPreferenceKey.self, value: $0.size.height)
        })
    }
    
    func onWidthChange(perform action: @escaping (CGFloat) -> Void) -> some View {
        onPreferenceChange(WidthPreferenceKey.self) { width in
            action(width)
        }
    }
    
    func onHeightChange(perform action: @escaping (CGFloat) -> Void) -> some View {
        onPreferenceChange(HeightPreferenceKey.self) { height in
            action(height)
        }
    }
    
    func readSize() -> some View {
        background(GeometryReader {
            Color.clear.preference(key: SizePreferenceKey.self, value: $0.size)
        })
    }
    
    func onSizeChange(perform action: @escaping (CGSize) -> Void) -> some View {
        onPreferenceChange(SizePreferenceKey.self) { size in
            action(size)
        }
    }
    
}

extension UIFont {
    func capHeight(forFontSize fontSize: CGFloat) -> CGFloat? {
        let descriptor = fontDescriptor.withSize(fontSize)
        let font = UIFont(descriptor: descriptor, size: fontSize)
        return font.capHeight
    }
}
