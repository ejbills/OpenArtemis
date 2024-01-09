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
    var body: some View {
        HStack {
            Spacer()
            if isLoading {
                ProgressView().padding(.horizontal, 2)
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
        .id(UUID())
    }
}
