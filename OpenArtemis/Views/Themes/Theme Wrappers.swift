//
//  Theme Wrappers.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/14/23.
//

import SwiftUI

struct ThemedList<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        List {
            content()
                .themedBackground(isListRow: true)
        }
        .scrollContentBackground(.hidden) // hide all scroll content bg so background shows up
        .themedBackground(isDarker: true)
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
        .themedBackground(isDarker: true)
    }
}
