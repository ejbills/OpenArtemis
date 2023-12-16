//
//  DividerView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/29/23.
//

import SwiftUI

struct DividerView: View {
    let frameHeight: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(height: frameHeight)
            .edgesIgnoringSafeArea(.all)
    }
}
