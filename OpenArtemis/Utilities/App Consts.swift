//
//  App Consts.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/29/23.
//

import Foundation
import SwiftUI

// Reddit backend
let baseRedditURL = "https://old.reddit.com"
let basePostCount = "25"

// Screen defaults
let roughWidth = UIScreen.main.bounds.width * 0.90
let roughHeight = UIScreen.main.bounds.height * 0.45

let portraitWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
let compactMultiplier = UIDevice.current.userInterfaceIdiom == .phone ? 0.15 : 0.085
let roughCompactWidth = portraitWidth * compactMultiplier
let roughCompactHeight = roughCompactWidth

extension UIScreen {
  static let screenWidth = UIScreen.main.bounds.size.width
  static let screenHeight = UIScreen.main.bounds.size.height
  static let screenSize = UIScreen.main.bounds.size
}

// Useful data
let drawerChars = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z", "#"]

// Other
let colorPalette: [Color] = [Color(hex: 0x648FFF), Color(hex: 0x785EF0), Color(hex: 0xDC267F), Color(hex: 0xFE6100), Color(hex: 0xFFB000)]
let tagBgColor = Color.gray.opacity(0.2)
