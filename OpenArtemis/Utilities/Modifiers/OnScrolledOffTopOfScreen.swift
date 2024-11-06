//
//  OnScrolledOffTopOfScreen.swift
//  OpenArtemis
//
//  Created by Michael DiGovanni on 11/6/24.
//
import SwiftUI

extension View {
    func onScrolledOffTopOfScreen(_ action: @escaping () -> Void) -> some View {
        self.modifier(DissappearUpModifier(action: action))
    }
}

struct DissappearUpModifier: ViewModifier {
    @State var appear: Bool = false
    
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .background(GeometryReader { geo -> Color in
                let yPosition = geo.frame(in: .global).minY
                DispatchQueue.main.async {
                    //                print("MIKEDG Dissappeared off the top")
                    
                    if yPosition < -200 && appear { // When the view is about to scroll off the screen at the top
                        appear = false
                        print("MIKEDG Dissappeared off the top")
                        //                    content.onDisappear() // was self
                        action()
                    } else if yPosition >= 0 && !appear { // When the view is inside the screen
                        appear = true
                    }
                }
                // Kinda hacky?
                return Color.clear // TODO: should this be a return?
            })
    }
}
