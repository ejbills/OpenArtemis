//
//  LoadingOverlay.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/30/23.
//

import SwiftUI

struct LoadingOverlay: ViewModifier {
    var isLoading: Bool
    var radius: CGFloat
        
    func body(content: Content) -> some View {
        ZStack {
            content
                .allowsHitTesting(!isLoading)
            if isLoading {
                ProgressView()
                Color.gray.opacity(0.15)
                    .cornerRadius(radius)
            }
        }
    }
}

struct AnimatedLoadingModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                withAnimation(.easeInOut(duration: 1)) {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.gray.opacity(0.6),
                            Color.gray.opacity(0.9)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .cornerRadius(6)
                }
            )
    }
}

extension View {
    func loadingOverlay(isLoading: Bool, radius: CGFloat? = nil) -> some View {
        self.modifier(LoadingOverlay(isLoading: isLoading, radius: radius ?? 6).animation(.smooth))
    }
    
    func animatedLoading() -> some View {
        self.modifier(AnimatedLoadingModifier())
    }
}
