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
                    .foregroundColor(Color.white)
                    .padding(6)
                    .frame(maxWidth: 30, maxHeight: 30)
                    .background{
                        RoundedRectangle(cornerSize: CGSize(width: 7, height: 7))
                            .foregroundStyle(iconColor)
                            .frame(width: 30, height: 30)
                    }
            }
        )
        .labelStyle(DefaultLabelStyle())
        .foregroundColor(.primary)
    }
}
