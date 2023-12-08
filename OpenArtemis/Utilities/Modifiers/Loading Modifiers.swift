//
//  LoadingOverlay.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/30/23.
//

import SwiftUI

struct LoadingOverlay: ViewModifier {
    var isLoading: Bool
    func body(content: Content) -> some View {
        ZStack {
            content
            if isLoading {
                ProgressView()
                
                Color.gray.opacity(0.45)
                    .cornerRadius(6)
            }
        }
    }
}

struct AnimatedLoadingModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                withAnimation(.easeInOut(duration: 0.5)) {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.gray.opacity(0.2),
                            Color.gray.opacity(0.9)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                }
            )
    }
}

extension View {
    func loadingOverlay(isLoading: Bool) -> some View {
        self.modifier(LoadingOverlay(isLoading: isLoading).animation(.snappy))
    }
    
    func animatedLoading() -> some View {
        self.modifier(AnimatedLoadingModifier())
    }
}
