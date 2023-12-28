//
//  Theme Wrappers.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/14/23.
//

import SwiftUI

struct ThemedList<Content: View>: View {
    let appTheme: AppThemeSettings
    let content: () -> Content

    init(appTheme: AppThemeSettings, @ViewBuilder content: @escaping () -> Content) {
        self.appTheme = appTheme
        self.content = content
    }

    var body: some View {
        List {
            content()
                .themedBackground(isListRow: true, appTheme: appTheme)
        }
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden) // hide all scroll content bg so background shows up
        .themedBackground(isDarker: true, appTheme: appTheme)
    }
}

struct ThemedScrollView<Content: View>: View {  
    let appTheme: AppThemeSettings
    let content: () -> Content

    init(appTheme: AppThemeSettings, @ViewBuilder content: @escaping () -> Content) {
        self.appTheme = appTheme
        self.content = content
    }

    var body: some View {
        ScrollView {
            content()
        }
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden) // hide all scroll content bg so background shows up
        .themedBackground(isDarker: true, appTheme: appTheme)
    }
}
