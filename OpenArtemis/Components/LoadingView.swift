//
//  LoadingAnimation.swift
//  OpenArtemis
//
//  Created by daniel on 02/12/23.
//

import SwiftUI

struct LoadingView: View {
    let loadingText: String
    let isLoading: Bool
    @State private var moveRightLeft = false
    var body: some View {
        HStack {
            Spacer()
            if isLoading {
                ProgressView().id(UUID()).padding(.horizontal, 2)
                Text(loadingText)
            } else {
                Text("Nothing here...")
            }
            Spacer()
        }
        .padding(6)
        .font(.subheadline)
        .italic()
        .foregroundStyle(.secondary)
    }
}
