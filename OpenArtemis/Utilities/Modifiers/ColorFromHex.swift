//
//  ColorFromHex.swift
//  OpenArtemis
//
//  Created by daniel on 05/12/23.
//

import Foundation
import SwiftUI

import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        // Extract red, green, and blue components from the hex value
        let red = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0x00FF00) >> 8) / 255.0
        let blue = Double(hex & 0x0000FF) / 255.0

        // Create a SwiftUI Color with the extracted components
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
}
