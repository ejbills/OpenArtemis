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
          VStack {
            Color.primary.opacity(0.05).frame(maxWidth: .infinity, maxHeight: 1)
            
            Spacer()
            
            Color.primary.opacity(0.05).frame(maxWidth: .infinity, maxHeight: 1)
          }
          .frame(height: frameHeight)
          .background(Rectangle().fill(Color.gray.opacity(0.15)))
          .edgesIgnoringSafeArea(.all)
        } else {
            Divider()
        }
    }
}
