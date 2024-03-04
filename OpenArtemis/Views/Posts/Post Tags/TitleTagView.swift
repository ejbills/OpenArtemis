//
//  TitleTagView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/19/23.
//

import SwiftUI
import Foundation

struct TitleTagView: View {
    let title: String
    let domain: String
    let tag: String
    let textSizePreference: TextSizePreference
    
    var body: some View {
        Text(attributedString)
            .font(textSizePreference.title)
    }
    
    private var attributedString: AttributedString {
        let domainAndTag: String = {
            guard !domain.isEmpty, let url = URL(string: domain), let host = url.host else {
                return tag
            }
            return "(\(host)) " + tag
        }()

        let fullText = title + " " + domainAndTag
        
        var attributedString = AttributedString(fullText)
        
        if let range = attributedString.range(of: domainAndTag, options: .backwards) {
            attributedString[range].foregroundColor = .secondary
            attributedString[range].font = textSizePreference.tag
            
            let middleOffset = (UIFont.systemFont(ofSize: textSizePreference.bodyFontSize).capHeight -
                                UIFont.systemFont(ofSize: textSizePreference.tagFontSize).capHeight) / 2
            attributedString[range].baselineOffset = middleOffset
        }

        return attributedString
    }
}
