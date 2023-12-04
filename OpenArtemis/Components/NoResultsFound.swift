//
//  NoResultsFound.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/3/23.
//

import SwiftUI

struct NoResultsFound: View {
//    var message: String
    @State private var moveRightLeft = false
    let screenFrame = Color(.systemBackground)

    var body: some View {
        ZStack {
            screenFrame
                .edgesIgnoringSafeArea(.all)

            VStack {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Color(.systemGray2))

                Text("No Results Found")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.secondary)

//                Text(message)
//                    .font(.subheadline)
//                    .italic()
//                    .foregroundStyle(.secondary)
//                    .padding(.horizontal, 20)
//                    .multilineTextAlignment(.center)
            }
        }
    }
}
