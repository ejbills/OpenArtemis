//
//  Defaults.swift
//  OpenArtemis
//
//  Created by daniel on 02/12/23.
//

import Foundation
import Defaults
import SwiftUI

extension Defaults.Keys {
    static let preferredThemeMode = Key<PreferredThemeMode>("preferredThemeMode", default: .automatic)
    static let accentColor = Key<Color>("accentColor", default: Color.blue)
    
    static let redirectToPrivateSites = Key<Bool>("accentColor", default: true)
    static let showOriginalURL = Key<Bool>("showOriginalURl", default: false)
    static let removeTrackingParams = Key<Bool>("removeTrackingParams", default: true)
    
    static let showJumpToNextCommentButton = Key<Bool>("showJumpToNextCommentButton", default: true)
}

enum PreferredThemeMode: Codable, CaseIterable, Identifiable, Defaults.Serializable {
    var id: Int {
        self.rawVal
    }
    
    case automatic
    case dark
    case light
    
    var rawVal: Int {
        switch self{
        case .automatic:
            0
        case .light:
            1
        case .dark:
            2
        }
    }
}
