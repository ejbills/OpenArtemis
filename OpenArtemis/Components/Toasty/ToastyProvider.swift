//
//  ToastyProvider.swift
//  To-day
//
//  Created by Igor Marcossi on 10/04/24.
//

import SwiftUI



extension View {
    func toastyRoot(alignment: Alignment = .bottom, margin: Double = 16) -> some View {
        self
            .overlay {
                GeometryReader { geo in
                    GeometryReader { geoFull in
                        ToastsManagerView(screenSize: geoFull.size, safeArea: geo.safeAreaInsets, alignment: alignment, margin: margin)
                    }
                    .ignoresSafeArea(.all)
                }
            }
    }
}
