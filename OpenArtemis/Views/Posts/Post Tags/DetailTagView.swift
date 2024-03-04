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
    
    init(icon: String? = nil, data: String, color: Color? = tagBgColor, paddingMultiplier: CGFloat? = 1, appTheme: AppThemeSettings) {
        self.icon = icon
        self.data = data
        self.color = color
        self.paddingMultiplier = paddingMultiplier
        self.appTheme = appTheme
    }
    
    var body: some View {
        HStack(spacing: 6 * (paddingMultiplier ?? 1)) {
            if let iconString = icon {
                Image(systemName: iconString)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 10, height: 10)
            }
            
            Text(data)
                .font(textSizePreference.footnote)
                .lineLimit(1)
        }
        .padding(.horizontal, 4 * (paddingMultiplier ?? 1))
        .padding(.vertical, 4 * (paddingMultiplier ?? 1))
        .background(RoundedRectangle(cornerRadius: 6).foregroundColor(color).opacity(appTheme.tagBackground ? 1 : 0))
    }
}
