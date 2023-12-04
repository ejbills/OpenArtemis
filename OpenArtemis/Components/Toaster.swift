//
//  Toaster.swift
//  OpenArtemis
//
//  Created by daniel on 04/12/23.
//

import SwiftUI

struct Toaster: ViewModifier {
    @Binding var isPresented: Bool
    var style: ToastStyle
    var title: String
    var systemIcon: String
    var speed: Double
    var duration: Double
    var animation: Animation
    var tapToDismiss: Bool
    var onAppear: () -> ()
    
    func body(content: Content) -> some View {
        content
            .overlay{
                VStack {
                    Spacer()
                    if isPresented {
                        switch style {
                        case .popup:
                            PopupToast(title: title,icon: systemIcon, tapToDismiss: tapToDismiss, isPresented: $isPresented, duration: duration)
                                .padding() // Add padding as needed
                        }
                    }
                }
                .animation(animation.speed(speed))
                .onAppear(perform: onAppear)
                
                
            }
        
    }
}


struct PopupToast: View {
    var title: String
    var icon: String
    var tapToDismiss: Bool
    @Binding var isPresented: Bool
    var duration: Double
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(10)
        .onTapGesture {
            if tapToDismiss {
                isPresented.toggle()
            }
        }
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                isPresented.toggle()
            }
        }
    }
}

/// Extension for the View protocol to add the toast modifier.
extension View {
    /// Applies the toast modifier to the view.
    ///
    /// - Parameters:
    ///   - isPresented: Binding for when it should be presented.
    ///   - style: Style of the toast.
    ///   - title: Title of the toast.
    ///   - systemIcon: System icon for the toast.
    ///   - speed: Speed of the animation in seconds.
    ///   - duration: Duration of the animation in seconds.
    ///   - animation: Type of animation.
    ///   - tapToDismiss: Tap to dismiss toast.
    ///   - onAppear: Action to perform on appearance.
    ///
    /// - Returns: A modified version of the view with the toast applied.
    func toast(
        isPresented: Binding<Bool>,
        style: ToastStyle = .popup,
        title: String,
        systemIcon: String = "checkmark.circle.fill",
        speed: Double = 1.0,
        duration: Double = 2.0,
        animation: Animation = .easeInOut,
        tapToDismiss: Bool = false,
        onAppear: @escaping () -> ()
    ) -> some View {
        modifier(Toaster(
            isPresented: isPresented,
            style: style,
            title: title,
            systemIcon: systemIcon,
            speed: speed,
            duration: duration,
            animation: animation,
            tapToDismiss: tapToDismiss,
            onAppear: onAppear
        ))
    }
}

/// Enum defining different toast styles.
enum ToastStyle {
    case popup
}
