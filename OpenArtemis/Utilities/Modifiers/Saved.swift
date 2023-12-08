//
//  Saved.swift
//  OpenArtemis
//
//  Created by daniel on 08/12/23.
//

import SwiftUI

struct Saved: ViewModifier {
    @Binding var isShowing: Bool
    @State var jankynessOffsetX: Double = 0
    @State var jankynessOffsetY: Double = 0
    func body(content: Content) -> some View {
            content
                .overlay{
                    isShowing ? HStack{
                        Spacer()
                        Triangle().path(in: CGRect(x: 0, y: 0, width: 30, height: 30))
                            .padding(.horizontal, jankynessOffsetX)
                            .padding(.vertical, jankynessOffsetY)
                            .foregroundStyle(.green)
                            .ignoresSafeArea()
                            .opacity(0.8)
                    }
                    .frame(maxWidth: .infinity)
                    : nil
                }
    }
}


struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start from the bottom left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        // Add line to the top middle
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        // Add line to the bottom right
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        // Close the path to create the third side of the triangle
        path.closeSubpath()

        return path
    }
}


extension View  {
    func savedIndicator(_ isShowing: Binding<Bool>, offset: (Double, Double) = (0,0))-> some View {
        self.modifier(Saved(isShowing: isShowing, jankynessOffsetX: offset.0, jankynessOffsetY: offset.1))
    }
}
