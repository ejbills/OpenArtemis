//
//  DefaultSubredditRowView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/2/23.
//

import SwiftUI

struct DefaultSubredditRowView: View {
    var title: String
    var iconSystemName: String
    var iconColor: Color

    var body: some View {
        Label(
            title: { Text(title) },
            icon: {
                Image(systemName: iconSystemName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(iconColor)
            }
        )
        .labelStyle(DefaultLabelStyle())
        .foregroundColor(.primary)
    }
}
