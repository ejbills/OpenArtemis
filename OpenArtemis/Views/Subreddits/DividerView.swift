//
//  DividerView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/29/23.
//

import SwiftUI
import Defaults

struct DividerView: View {
    let frameHeight: CGFloat
    let appTheme: AppThemeSettings
    
    var body: some View {
        if !appTheme.thinDivider {
            Rectangle()
                .fill(Color.gray.opacity(0.15))
                .frame(height: frameHeight)
                .edgesIgnoringSafeArea(.all)
        } else {
            Divider()
        }
    }
}
