//
//  DetailTagView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/28/23.
//

import SwiftUI
import Defaults

struct DetailTagView: View {
    let icon: String?
    let data: String
    let color: Color?
    let paddingMultiplier: CGFloat?
    let appTheme: AppThemeSettings
    let textSizePreference: TextSizePreference
    let onTap: (() -> Void)?
    
    init(icon: String? = nil, data: String, color: Color? = tagBgColor, paddingMultiplier: CGFloat? = 1, appTheme: AppThemeSettings, textSizePreference: TextSizePreference, onTap: (() -> Void)? = nil) {
        self.icon = icon
        self.data = data
        self.color = color
        self.paddingMultiplier = paddingMultiplier
        self.appTheme = appTheme
        self.textSizePreference = textSizePreference
        self.onTap = onTap
    }
    
    var body: some View {
        if let onTap {
            AnimatedButtonPress(content: {
                groupContent()
            }, onTap: {
                onTap()
            }, cornerRadius:  CGSize(width: 12.0, height: 12.0))
        } else {
            groupContent()
        }
    }
    
    @ViewBuilder
    private func groupContent() -> some View {
        HStack(spacing: 6 * (paddingMultiplier ?? 1)) {
            if let iconString = icon {
                Image(systemName: iconString)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 10 * (paddingMultiplier ?? 1), height: 10 * (paddingMultiplier ?? 1))
            }
            
            Text(data)
                .font(textSizePreference.tag)
                .lineLimit(1)
        }
        .padding(.horizontal, 9 * (paddingMultiplier ?? 1))
        .padding(.vertical, 4 * (paddingMultiplier ?? 1))
        .background(RoundedRectangle(cornerRadius: 12).foregroundColor(color).opacity(appTheme.tagBackground ? 1 : 0))
    }
}
