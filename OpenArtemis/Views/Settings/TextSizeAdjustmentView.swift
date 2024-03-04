//
//  TextSizeAdjustmentView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 3/4/24.
//

import SwiftUI
import Defaults

struct TextSizeAdjustmentView: View {
    @Default(.textSizePreference) var textSizePreference
    
    var body: some View {
        VStack {
            TextSizeAdjustmentRow(label: "Title", fontSize: $textSizePreference.titleFontSize, textSizePreference: textSizePreference)
            TextSizeAdjustmentRow(label: "Title 2", fontSize: $textSizePreference.title2FontSize, textSizePreference: textSizePreference)
            TextSizeAdjustmentRow(label: "Title 3", fontSize: $textSizePreference.title3FontSize, textSizePreference: textSizePreference)
            TextSizeAdjustmentRow(label: "Headline", fontSize: $textSizePreference.headlineFontSize, textSizePreference: textSizePreference)
            TextSizeAdjustmentRow(label: "Subheadline", fontSize: $textSizePreference.subheadlineFontSize, textSizePreference: textSizePreference)
            TextSizeAdjustmentRow(label: "Body", fontSize: $textSizePreference.bodyFontSize, textSizePreference: textSizePreference)
            TextSizeAdjustmentRow(label: "Callout", fontSize: $textSizePreference.calloutFontSize, textSizePreference: textSizePreference)
            TextSizeAdjustmentRow(label: "Caption", fontSize: $textSizePreference.captionFontSize, textSizePreference: textSizePreference)
            TextSizeAdjustmentRow(label: "Caption 2", fontSize: $textSizePreference.caption2FontSize, textSizePreference: textSizePreference)
            TextSizeAdjustmentRow(label: "Footnote", fontSize: $textSizePreference.footnoteFontSize, textSizePreference: textSizePreference)
            
            Text("Customize the text size to fit your preference.")
                .font(textSizePreference.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
        .navigationTitle("Adjust Font Size")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TextSizeAdjustmentRow: View {
    var label: String
    @Binding var fontSize: CGFloat
    let textSizePreference: TextSizePreference
    
    var body: some View {
        HStack {
            Text(label)
                .font(textSizePreference.body)
                .foregroundColor(.secondary)
                .padding()
            
            TextField("Font Size", value: $fontSize, formatter: NumberFormatter())
                .multilineTextAlignment(.center)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Text("Example Text")
                .font(.system(size: fontSize))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }
}
