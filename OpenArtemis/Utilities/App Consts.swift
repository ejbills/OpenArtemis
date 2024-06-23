//
//  App Consts.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/29/23.
//

import Foundation
import SwiftUI
import Defaults

// Reddit backend
let baseRedditURL = "https://old.reddit.com"
let newBaseRedditURL = "https://reddit.com"
let basePostCount = "25"

// Screen defaults
let roughWidth = UIScreen.main.bounds.width * 0.90
let roughHeight = UIScreen.main.bounds.height * 0.45

let device = UIDevice.current.userInterfaceIdiom
let isPhone = device == .phone

let portraitWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
let compactMultiplier = isPhone ? 0.15 : 0.085
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
let tagBgColor = Color.gray.opacity(0.125)
