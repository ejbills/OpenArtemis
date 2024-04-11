//
//  Toasty.swift
//  To-day
//
//  Created by Igor Marcossi on 10/04/24.
//

import SwiftUI

@Observable
final class Toasty {
    static let addToastSpringDuration: Double = 0.5
    static let shared = Toasty()
    // Utility function
    static func fire(_ toast: Toast) { Toasty.shared.fire(toast) }
    static func dismiss(_ toast: Toast? = nil) { Toasty.shared.dismiss(toast) }
    static func dismissAll() { Toasty.shared.toasts.forEach { Toasty.shared.dismiss($0) } }
    
    private let dispatchQueue = DispatchQueue.main
    
    var toasts = [Toast]()
    
    func fire(_ toast: Toast) {
        dispatchQueue.async {
            withAnimation(.spring(duration: Toasty.addToastSpringDuration)) {
                self.toasts.append(toast)
            }
            DispatchQueue.main.async {
                toast.scheduleAutoDismiss()
            }
        }
    }
    
    func dismiss(_ toast: Toast? = nil) {
        if toasts.count == 0 { return }
        let toast = toast ?? self.toasts[self.toasts.count - 1]
        dispatchQueue.async {
            withAnimation(.spring) {
                self.toasts = self.toasts.filter({ $0 != toast })
                toast.onDismiss?()
            }
        }
    }
    
    @Observable
    class Toast: Equatable, Identifiable {
        static func == (lhs: Toasty.Toast, rhs: Toasty.Toast) -> Bool { lhs.id == rhs.id}
        
        let id = UUID()
        let icon: String?
        let message: String
        var textColor: Color
        var duration: CGFloat
        var animateIcon: Bool
        let onDismiss: (() -> ())?
        let onTap: ((_ toast: Toasty.Toast) -> ())?
        private var dismissTimer: Timer?
        
        init(
            icon: String? = nil,
            message: String,
            textColor: Color = .primary,
            duration: CGFloat = 1,
            animateIcon: Bool = true,
            onDismiss: (() -> Void)? = nil,
            onTap: ( (_ toast: Toasty.Toast) -> Void)? = nil
        ) {
            self.icon = icon
            self.message = message
            self.textColor = textColor
            self.duration = duration
            self.animateIcon = animateIcon
            self.onDismiss = onDismiss
            self.onTap = onTap
        }
        
        func dismiss() {
            self.cancelAutoDismiss();
            Toasty.shared.dismiss(self)
        }
        
        func cancelAutoDismiss() { self.dismissTimer?.invalidate() }
        
        func scheduleAutoDismiss() {
            if duration != .infinity {
                self.dismissTimer = Timer.scheduledTimer(
                    withTimeInterval: Toasty.addToastSpringDuration + self.duration, repeats: false
                ) { _ in
                    self.dismiss()
                }
            }
        }
    }
}
