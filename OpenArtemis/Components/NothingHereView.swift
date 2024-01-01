//
//  NothingHereView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/31/23.
//

import SwiftUI

struct NothingHereView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Nothing to see here! Please make a selection in the sidebar.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
        .edgesIgnoringSafeArea(.all)
    }
}
