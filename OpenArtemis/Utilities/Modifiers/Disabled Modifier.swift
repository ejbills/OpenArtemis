//
//  Disabled Modifier.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/2/23.
//

import SwiftUI

struct DisabledViewModifier: ViewModifier {
    var isEnabled: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isEnabled ? 1.0 : 0.5)
            .disabled(!isEnabled)
    }
}

extension View {
    func disabledView(isEnabled: Bool) -> some View {
        self.modifier(DisabledViewModifier(isEnabled: isEnabled))
    }
}
