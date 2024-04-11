//
//  BouncyIcon.swift
//  To-day
//
//  Created by Igor Marcossi on 10/04/24.
//

import SwiftUI

struct BouncyIcon: View, Equatable {
    static func == (lhs: BouncyIcon, rhs: BouncyIcon) -> Bool {
        lhs.icon == rhs.icon && lhs.animateIcon == rhs.animateIcon
    }
    var icon: String
    var animateIcon: Bool
    @State private var jump = 0
    var body: some View {
        Image(systemName: icon)
            .symbolEffect(.bounce, value: jump)
            .onAppear {
                if animateIcon {
                    DispatchQueue.main.asyncAfter(deadline: .now() + (Toasty.addToastSpringDuration / 2)) {
                        withAnimation { jump += 1 }
                    }
                }
            }
    }
}
