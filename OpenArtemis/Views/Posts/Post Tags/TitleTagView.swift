//
//  TitleTagView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/19/23.
//

import SwiftUI

struct TitleTagView: View {
    let title: String
    let tag: String
    
    var body: some View {
        Text(attributedString)
            .cornerRadius(6)
    }
    
    private var attributedString: AttributedString {
        let fullText = title + " " + tag
        var attributedString = AttributedString(fullText)

        if let range = attributedString.range(of: tag, options: .backwards) {
            attributedString[range].foregroundColor = Color.artemisAccent
            attributedString[range].font = .footnote
            
            let middleOffset = (UIFont.preferredFont(forTextStyle: .body).capHeight - UIFont.preferredFont(forTextStyle: .footnote).capHeight) / 2
            attributedString[range].baselineOffset = middleOffset
        }

        return attributedString
    }
}


