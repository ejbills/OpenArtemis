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

///Tracks the first time that the view is scrolled up off the screen
private struct DissappearUpModifier: ViewModifier {
    @State var dissappeared: Bool = false
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .background(GeometryReader { geo -> Color in
                let yPosition = geo.frame(in: .global).minY
                let height = geo.frame(in: .local).height // Help determine when entire view has been scrolled up
                
                // Does not take into account nav bar height
                if yPosition < (0 - height) && !dissappeared { // When the view is about to scroll off the screen at the top
                    dissappeared = true
                    DispatchQueue.main.async {
                        action()
                    }
                }
            
                return Color.clear
            })
    }
}
