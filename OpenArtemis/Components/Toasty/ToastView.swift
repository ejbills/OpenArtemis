//
//  ToastView.swift
//  To-day
//
//  Created by Igor Marcossi on 10/04/24.
//

import SwiftUI

struct ToastView: View {
    static let height: Double = 56
    static let velocityToDismiss: Double = 350
    var toast: Toasty.Toast
    var dismissOffset: Double
    @State private var finalOffset: Double = 0
    @GestureState private var dragOffset: Double?
    var body: some View {
        let dismissOffsetWithHeight = self.dismissOffset + Self.height
        let pressing = dragOffset != nil
        let offset = dragOffset ?? finalOffset
        HStack(spacing: 8) {
            if let icon = toast.icon {
                BouncyIcon(icon: icon, animateIcon: toast.animateIcon)
            }
            Text(toast.message)
        }
        .padding(.horizontal, 20)
        .frame(height: Self.height)
        .background {
            Capsule(style: .continuous).fill(Material.bar)
                .overlay {
                  Capsule(style: .continuous)
                    .stroke(Color.primary.opacity(0.05), lineWidth: 0.5)
                    .padding(.all, 0.5)
                }
        }
        .geometryGroup()
        .scaleEffect(pressing ? 0.95 : 1)
        .offset(y: offset)
        .animation(.spring, value: dragOffset == nil)
        .onTapGesture { toast.onTap?(toast) }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .updating($dragOffset) { dragVal, state, trans in
                    let transHeight = dragVal.translation.height
                    let oppositeDir = (dismissOffset < 0 && transHeight > 0) || (dismissOffset > 0 && transHeight < 0)
                    let velocity: Double = oppositeDir ? 0.1 : 1
                    trans.animation = .interactiveSpring
                    state = transHeight * velocity
                }
                .onEnded { dragVal in
                    let vel = dragVal.velocity.height
                    if (vel > Self.velocityToDismiss && dismissOffset > 0) || (vel < -(Self.velocityToDismiss) && dismissOffset < 0) {
                        withAnimation(.interpolatingSpring(.smooth)) {
                            toast.cancelAutoDismiss()
                            finalOffset = dismissOffsetWithHeight
                        } completion: {
                            toast.dismiss()
                        }
                    }
                }
        )
        .onChange(of: pressing) { _, newVal in
            if newVal {
                HapticManager.shared.singleClick()
                toast.cancelAutoDismiss()
            } else {
                toast.scheduleAutoDismiss()
            }
        }
        .font(.system(size: 17, weight: .medium))
        .foregroundStyle(toast.textColor)
        .transition(.offset(y: dismissOffsetWithHeight))
    }
}

