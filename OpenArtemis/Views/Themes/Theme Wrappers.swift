//
//  Theme Wrappers.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/14/23.
//

import Defaults
import SwiftUI

struct ThemedList<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        List {
            content()
                .listRowBackground(Color.themeBackgroundColor)
        }
        .scrollContentBackground(.hidden) // hide all scroll content bg so background shows up
        .background(Color.themeBackgroundColor.darker(by: 3))
    }
}

struct ThemedScrollView<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        ScrollView {
            content()
        }
        .scrollContentBackground(.hidden) // hide all scroll content bg so background shows up
        .background(Color.themeBackgroundColor.darker(by: 3))
        .listRowBackground(Color.themeBackgroundColor)
    }
}

extension UIColor {
    func darker(by percentage: CGFloat) -> UIColor {
        return self.adjust(by: -abs(percentage))
    }

    private func adjust(by percentage: CGFloat) -> UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return self
        }
        return UIColor(red: max(red + percentage/100, 0.0),
                       green: max(green + percentage/100, 0.0),
                       blue: max(blue + percentage/100, 0.0),
                       alpha: alpha)
    }
}
