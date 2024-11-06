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
    
    static let commentColorPalette = Key<[Color]>("commentColorPalette", default: ColorPalettes.defaultPalette)
    
    // MARK: - General
    static let redirectToPrivateSites = Key<Bool>("redirectToPrivateSites", default: true)
    static let readerMode = Key<Bool>("readerMode", default: true)
    static let removeTrackingParams = Key<Bool>("removeTrackingParams", default: true)
    static let over18 = Key<Bool>("over18", default: false)
    static let swipeAnywhere = Key<Bool>("swipeAnywhere", default: false)
    static let showJumpToNextCommentButton = Key<Bool>("showJumpToNextCommentButton", default: true)
    static let doLiveText = Key<Bool>("doLiveText", default: true)
    static let hideReadPosts = Key<Bool>("hideReadPosts", default: false)
    static let markReadOnScroll = Key<Bool>("markReadOnScroll", default: false)
    
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

struct ColorPalettes {
    static let defaultPalette: [Color] = [
        Color(hex: 0x648FFF), Color(hex: 0x785EF0),
        Color(hex: 0xDC267F), Color(hex: 0xFE6100),
        Color(hex: 0xFFB000)
    ]

    static let sunsetPalette: [Color] = [
        Color(hex: 0xFFADAD),
        Color(hex: 0xFFD6A5),
        Color(hex: 0xFDFFB6),
        Color(hex: 0xCAFFBF),
        Color(hex: 0x9BF6FF)
    ]

    static let oceanPalette: [Color] = [
        Color(hex: 0x2b699c),
        Color(hex: 0x4087ca),
        Color(hex: 0x519ebb),
        Color(hex: 0x3f88d2),
        Color(hex: 0x5a8db5)
    ]

    static let forestPalette: [Color] = [
        Color(hex: 0x3d6145),
        Color(hex: 0x6d8153),
        Color(hex: 0x5e9c4a),
        Color(hex: 0x8da772),
        Color(hex: 0x9f9f4f)
    ]

    static let grayscalePalette: [Color] = [
        Color(hex: 0x3c4049),
        Color(hex: 0x454951),
        Color(hex: 0x424247),
        Color(hex: 0x55585e),
        Color(hex: 0x666970)
    ]

    static let autumnPalette: [Color] = [
        Color(hex: 0xB7410E),
        Color(hex: 0xCC5500),
        Color(hex: 0xDAA520),
        Color(hex: 0x8B4513),
        Color(hex: 0xCD853F)
    ]

    static let twilightPalette: [Color] = [
        Color(hex: 0xb46654),
        Color(hex: 0x65b80ad),
        Color(hex: 0x8178ad),
        Color(hex: 0xb79a60),
        Color(hex: 0x558f68)
    ]

    static let allPalettes: [[Color]] = [
        defaultPalette, sunsetPalette, oceanPalette,
        forestPalette, grayscalePalette, autumnPalette, twilightPalette
    ]
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
