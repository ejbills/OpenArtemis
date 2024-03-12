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
    // MARK: - Theming
    static let preferredThemeMode = Key<PreferredThemeMode>("preferredThemeMode", default: .automatic)
    static let accentColor = Key<Color>("accentColor", default: Color.blue)
    static let appTheme = Key<AppThemeSettings>("appTheme", default: AppThemeSettings())
    static let textSizePreference = Key<TextSizePreference>("textSizePreference", default: TextSizePreference())
    
    // MARK: - General
    static let redirectToPrivateSites = Key<Bool>("accentColor", default: true)
    static let readerMode = Key<Bool>("readerMode", default: true)
    static let removeTrackingParams = Key<Bool>("removeTrackingParams", default: true)
    static let over18 = Key<Bool>("over18", default: false)
    static let swipeAnywhere = Key<Bool>("swipeAnywhere", default: false)
    static let showJumpToNextCommentButton = Key<Bool>("showJumpToNextCommentButton", default: true)
    static let doLiveText = Key<Bool>("doLiveText", default: true)
    static let hideReadPosts = Key<Bool>("hideReadPosts", default: false)
    
    static let defaultPostPageSorting = Key<SortOption>("defaultPostPageSorting", default: SortOption.best)
    static let defaultSubSorting = Key<SortOption>("defaultSubSorting", default: SortOption.best)
    
    static let defaultLaunchFeed = Key<String>("defaultLaunchFeed", default: "favList")
    static let hideFavorites = Key<Bool>("hideFavorites", default: false)
    
    static let showingOOBE = Key<Bool>("showingOOBE", default: true)
    static let seenCaseSensitiveDisclaimer = Key<Bool>("seenCaseSensitiveDisclaimer", default: false)
    
    // MARK: - Website Redirects
    static let youtubeRedirect = Key<String>("youtubeRedirect", default: "yewtu.be")
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

struct AppThemeSettings: Equatable, Hashable, Codable, Defaults.Serializable {
    var preferredThemeMode: PreferredThemeMode = .automatic
    
    var compactMode: Bool = false
    var thinDivider: Bool = false
    var tagBackground: Bool = true
    var highlightSubreddit: Bool = true
    var highlightAuthor: Bool = false
    var showAuthor: Bool = true
    var showOriginalURL: Bool = false

    var lightBackground: Color = .white
    var darkBackground: Color = Color(hex: "111112")
}

struct TextSizePreference: Codable, Defaults.Serializable {
    var titleFontSize: CGFloat = 16
    var bodyFontSize: CGFloat = 16
    var captionFontSize: CGFloat = 12
    var tagFontSize: CGFloat = 12
    
    var multiplier: CGFloat = 1
    
    // Computed properties to generate Font instances with default Apple font
    var title: Font {
        .system(size: titleFontSize)
    }
    
    var body: Font {
        .system(size: bodyFontSize)
    }
    
    var caption: Font {
        .system(size: captionFontSize)
    }
    
    var tag: Font {
        .system(size: tagFontSize)
    }
    
    // Generate Font instance with size multiplied by the multiplier
    func sizeWithMult(fontSize: CGFloat) -> Font {
        return .system(size: fontSize * multiplier)
    }
}
