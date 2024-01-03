//
//  ReadModifier.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 1/1/24.
//

import SwiftUI

struct ReadModifier: ViewModifier {
    let isRead: Bool
    func body(content: Content) -> some View {
        content
            .opacity(isRead ? 0.55 : 1)
    }
}

extension View {
    func markRead(isRead: Bool) -> some View {
        self.modifier(ReadModifier(isRead: isRead))
    }
}
