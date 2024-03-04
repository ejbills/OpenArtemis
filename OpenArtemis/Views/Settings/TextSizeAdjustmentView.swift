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
    let appTheme: AppThemeSettings
    
    var body: some View {
        ThemedList(appTheme: appTheme, textSizePreference: textSizePreference) {
            
            Section("Adjust font size") {
                TextSizeAdjustmentRow(label: "Title", fontSize: $textSizePreference.titleFontSize, textSizePreference: textSizePreference)
                TextSizeAdjustmentRow(label: "Body", fontSize: $textSizePreference.bodyFontSize, textSizePreference: textSizePreference)
                TextSizeAdjustmentRow(label: "Caption", fontSize: $textSizePreference.captionFontSize, textSizePreference: textSizePreference)
                TextSizeAdjustmentRow(label: "Tag", fontSize: $textSizePreference.tagFontSize, textSizePreference: textSizePreference)
                
                VStack {
                    Text("This is an example title")
                        .font(textSizePreference.title)
                    Text("This is an example body")
                        .font(textSizePreference.body)
                    Text("This is an example caption")
                        .font(textSizePreference.caption)
                    Text("This is an example tag")
                        .font(textSizePreference.tag)
                }
                .padding()
                .multilineTextAlignment(.center)
            }
        }
        .navigationTitle("Adjust Font Size")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
            Button("Reset") {
                _textSizePreference.reset()
            }
        )
    }
}

struct TextSizeAdjustmentRow: View {
    var label: String
    @Binding var fontSize: CGFloat
    let textSizePreference: TextSizePreference
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(label)
                    .font(textSizePreference.body)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                TextField("Font Size", value: $fontSize, formatter: NumberFormatter())
                    .multilineTextAlignment(.center)
                    .keyboardType(.numbersAndPunctuation)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 60)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 8)
    }
}
