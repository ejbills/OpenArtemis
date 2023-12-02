//
//  AccentColorModifier.swift
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
}
