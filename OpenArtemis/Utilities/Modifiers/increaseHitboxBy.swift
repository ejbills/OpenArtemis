//
//  increaseHitboxBy.swift
//  winston
//
//  Created by Igor Marcossi on 28/12/23.
//

import SwiftUI

extension View {
    func increaseHitboxBy<S: Shape>(_ amount: Double, shape: S = Rectangle(), disable: Bool = false) -> some View {
        self.background(GeometryReader { geometry in
            Color.clear
                .frame(width: geometry.size.width * CGFloat(disable ? 1 : amount),
                       height: geometry.size.height * CGFloat(disable ? 1 : amount))
                .contentShape(shape)
        })
    }
}
