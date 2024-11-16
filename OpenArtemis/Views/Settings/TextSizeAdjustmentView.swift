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
    
    private let minFontSize: CGFloat = 8
    private let maxFontSize: CGFloat = 32
    
    var body: some View {
        ThemedList(appTheme: appTheme, textSizePreference: textSizePreference) {
            Section {
                Text("Drag the sliders to adjust text sizes. Changes will be reflected across the app.")
                    .font(textSizePreference.caption)
                    .foregroundColor(.secondary)
            }
            
            Section("Adjustments") {
                FontSizeSlider(
                    label: "Title",
                    size: $textSizePreference.titleFontSize,
                    range: minFontSize...maxFontSize,
                    textSizePreference: textSizePreference
                )
                
                FontSizeSlider(
                    label: "Body",
                    size: $textSizePreference.bodyFontSize,
                    range: minFontSize...maxFontSize,
                    textSizePreference: textSizePreference
                )
                
                FontSizeSlider(
                    label: "Caption",
                    size: $textSizePreference.captionFontSize,
                    range: minFontSize...maxFontSize,
                    textSizePreference: textSizePreference
                )
                
                FontSizeSlider(
                    label: "Tag",
                    size: $textSizePreference.tagFontSize,
                    range: minFontSize...maxFontSize,
                    textSizePreference: textSizePreference
                )
            }
            
            Section("Preview") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Title Example")
                        .font(textSizePreference.title)
                        .foregroundColor(.artemisAccent)
                    
                    Text("This is how body text will appear throughout the app. It should be comfortable to read and clear.")
                        .font(textSizePreference.body)
                    
                    Text("Captions provide additional context")
                        .font(textSizePreference.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("Tag")
                            .font(textSizePreference.tag)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.artemisAccent.opacity(0.2))
                            .cornerRadius(4)
                        
                        Text("Another Tag")
                            .font(textSizePreference.tag)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.artemisAccent.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Font Size")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Reset") {
                    withAnimation {
                        _textSizePreference.reset()
                    }
                }
            }
        }
    }
}

struct FontSizeSlider: View {
    let label: String
    @Binding var size: CGFloat
    let range: ClosedRange<CGFloat>
    let textSizePreference: TextSizePreference
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(textSizePreference.body)
                Spacer()
                Text("\(Int(size))")
                    .font(textSizePreference.caption)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
            
            HStack(spacing: 12) {
                Image(systemName: "textformat.size.smaller")
                    .foregroundColor(.secondary)
                
                Slider(value: $size, in: range, step: 1) { editing in
                    if !editing {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
                .tint(Color.artemisAccent)
                
                Image(systemName: "textformat.size.larger")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
