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
    static let over18 = Key<Bool>("over18", default: false)
    
    static let showJumpToNextCommentButton = Key<Bool>("showJumpToNextCommentButton", default: true)
    
    static let showingOOBE = Key<Bool>("showingOOBE", default: true)
    
    
    // MARK: - Website Redirects
    static let youtubeRedirect = Key<String>("youtubeRedirect", default: "yewtu.be")
    static let twitterRedirect = Key<String>("twitterRedirect", default: "nitter.net")
    static let mediumRedirect = Key<String>("mediumRedirect", default: "scribe.rip")
    static let imgurRedirect = Key<String>("imgurRedirect", default: "rimgo.hostux.net")
    
    
    // MARK: - Stats
    static let trackStats = Key<Bool>("trackStats", default: true)
    static let trackersRemoved = Key<Int>("trackersRemoved", default: 0)
    static let URLsRedirected = Key<Int>("URLsRedirected", default: 0)
    
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
