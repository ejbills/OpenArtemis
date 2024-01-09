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
    let stripStyling: Bool

    init(appTheme: AppThemeSettings, stripStyling: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.appTheme = appTheme
        self.stripStyling = stripStyling
        self.content = content
    }

    var body: some View {
        Group {
            if stripStyling {
                List {
                    content()
                        .themedBackground(isListRow: true, appTheme: appTheme)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                }
                .scrollContentBackground(.hidden)
                .environment(\.defaultMinListRowHeight, 0)
            } else {
                List {
                    content()
                        .themedBackground(isListRow: true, appTheme: appTheme)
                }
                .scrollContentBackground(.hidden)
                .listSectionSpacing(2)
            }
        }
        .scrollIndicators(.hidden)
        .themedBackground(isDarker: true, appTheme: appTheme)
    }
}
