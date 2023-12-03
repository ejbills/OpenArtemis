//
//  Disabled Modifier.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/2/23.
//

import SwiftUI

struct DisabledViewModifier: ViewModifier {
    var disabled: Bool

    func body(content: Content) -> some View {
        content
            .opacity(!disabled ? 1.0 : 0.5)
            .disabled(disabled)
    }
}

extension View {
    func disabledView(disabled: Bool) -> some View {
        self.modifier(DisabledViewModifier(disabled: disabled))
    }
}
