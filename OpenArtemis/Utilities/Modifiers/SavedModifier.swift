//
//  SavedModifier.swift
//  OpenArtemis
//
//  Created by daniel on 08/12/23.
//

import SwiftUI

struct Saved: ViewModifier {
    var isShowing: Bool

    func body(content: Content) -> some View {
        content
            .overlay {
                isShowing ?
                    HStack {
                        Spacer()
                        VStack {
                            Triangle()
                                .path(in: CGRect(x: 0, y: 0, width: 30, height: 30))
                                .frame(width: 30, height: 30)
                                .foregroundStyle(.green)
                                .opacity(0.8)
                            Spacer()
                        }
                    }
                    .transition(.slide) // Add a transition
                    .frame(maxWidth: .infinity)
                : nil
            }
    }
}

// Add a Slide transition
extension AnyTransition {
    static var slide: AnyTransition {
        let insertion = AnyTransition.move(edge: .trailing)
            .combined(with: .opacity)
        let removal = AnyTransition.move(edge: .leading)
            .combined(with: .opacity)
        return .asymmetric(insertion: insertion, removal: removal)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start from the top left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        // Add line to the top right
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        // Add line to the bottom right
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        // Close the path to create the triangle
        path.closeSubpath()

        return path
    }
}

extension View {
    func savedIndicator(_ isShowing: Bool) -> some View {
        self.modifier(Saved(isShowing: isShowing))
    }
}
