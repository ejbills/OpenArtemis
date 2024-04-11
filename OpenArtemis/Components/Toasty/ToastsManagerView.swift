//
//  ToastsManagerView.swift
//  To-day
//
//  Created by Igor Marcossi on 10/04/24.
//

import SwiftUI

struct ToastsManagerView: View, Equatable {
    static let toastsSpacing: Double = 6
    var screenSize: CGSize
    var safeArea: EdgeInsets
    var alignment: Alignment
    var margin: Double
    var body: some View {
        let top = alignment == .top
            ZStack(alignment: alignment) {
                VStack(spacing: Self.toastsSpacing) {
                    ForEach(Array(Toasty.shared.toasts.enumerated()), id: \.element.id) { i, toast in
                        let extraSpace = Double(Toasty.shared.toasts.count - 1 - i) * (ToastView.height + Self.toastsSpacing)
                        ToastView(
                            toast: toast,
                            dismissOffset: ((top ? safeArea.top : safeArea.bottom) + margin + extraSpace) * (top ? -1 : 1)
                        )
                    }
                }
                .animation(.spring, value: Toasty.shared.toasts.count)
            }
            .padding(EdgeInsets(top: margin + safeArea.top, leading: 0, bottom: margin + safeArea.bottom, trailing: 0))
            .frame(width: screenSize.width, height: screenSize.height, alignment: alignment)
    }
}
