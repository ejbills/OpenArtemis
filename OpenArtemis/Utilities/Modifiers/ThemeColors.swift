//
//  ThemeColors.swift
//  OpenArtemis
//
//  Created by daniel on 02/12/23.
//

import Foundation
import SwiftUI
import Defaults


extension Color {
    /// This is the accent Color for the app which can be modified by the user in Settings
    static let artemisAccent = Defaults[.accentColor]
    
    static var themeBackgroundColor: Color {
        let preferredThemeMode = Defaults[.preferredThemeMode]
        let lightBackground = Defaults[.lightBackground]
        let darkBackground = Defaults[.darkBackground]
        
        let isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark

        switch preferredThemeMode.id {
        case 0:
            // Use the current color scheme for light or dark with the custom bg
            return isDarkMode ? darkBackground : lightBackground
        case 1:
            return lightBackground
        case 2:
            return darkBackground
        default:
            return Color(uiColor: UIColor.secondarySystemBackground)
        }
    }
    
    func darker(by percentage: CGFloat) -> Color {
        let baseUIColor = UIColor(self)
        let darkenedUIColor = baseUIColor.darker(by: percentage)
        return Color(darkenedUIColor)
    }
}

