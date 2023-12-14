//
//  HeroBox.swift
//  OpenArtemis
//
//  Created by daniel on 10/12/23.
//

import SwiftUI

struct HeroBox: View {
    var bigText: String
    var littleText: String
    var body: some View {
        VStack{
            HStack{
                Text(bigText)
                    .font(.title)
                    .fontWeight(.semibold)
                Spacer()
            }
            HStack {
                Text(littleText)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .font(.caption)
                    .opacity(0.5)
                Spacer()
            }
        }
        .padding()
        .background{
            RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                .foregroundStyle(.background)
        }
    }
}

