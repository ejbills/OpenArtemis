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
//    let color: Color?
//    let paddingMultiplier: CGFloat?
    let appTheme: AppThemeSettings
    let textSizePreference: TextSizePreference
    
    var body: some View {
        HStack(spacing: 4) {
            if let iconString = icon {
                Image(systemName: iconString)
            }
            
            Text(data)
                .lineLimit(1)
        }
        .font(textSizePreference.tag)
        .foregroundStyle(.blue)
//        .padding(.horizontal, 4 * (paddingMultiplier ?? 1))
//        .padding(.vertical, 4 * (paddingMultiplier ?? 1))
//        .background(RoundedRectangle(cornerRadius: 6).foregroundColor(color).opacity(appTheme.tagBackground ? 1 : 0))
    }
}
