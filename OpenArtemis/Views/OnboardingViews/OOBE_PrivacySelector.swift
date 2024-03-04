//
//  PrivacySelector.swift
//  OpenArtemis
//
//  Created by daniel on 13/12/23.
//

import SwiftUI

struct OOBE_PrivacySelector: View {
    let appTheme: AppThemeSettings
    let textSizePreference: TextSizePreference
    var body: some View {
        Text("Choose OpenArtemis to guide you to more private website alternatives. You can also enable the automatic removal of tracking parameters from all links.")
            .padding(.top, 8)
            .padding(.horizontal)
            .opacity(0.8)
        ThemedList(appTheme: appTheme, textSizePreference: textSizePreference) {
            RedirectWebsitesView()
            RemoveTrackinParamsView()
        }
        Spacer()
    }
        
}

