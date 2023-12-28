//
//  LoadingAnimation.swift
//  OpenArtemis
//
//  Created by daniel on 02/12/23.
//

import SwiftUI

struct LoadingAnimation: View {
    let loadingText: String
    let isLoading: Bool
    @State private var moveRightLeft = false
    var body: some View {
        LazyVStack {
            if isLoading {
                Text(loadingText)
                    .font(.subheadline)
                    .italic()
                    .foregroundStyle(.secondary)
                
                ZStack {
                    Capsule()
                        .frame(width: 128, height: 6, alignment: .center)
                        .foregroundColor(Color(.systemGray4))
                    Capsule()
                        .clipShape(Rectangle().offset(x: moveRightLeft ? 80 : -80))
                        .frame(width: 100, height: 6, alignment: .leading)
                        .offset(x: moveRightLeft ? 14 : -14)
                        .foregroundColor(Color.artemisAccent)
                        .onAppear{
                            withAnimation(Animation.easeInOut(duration: 0.5).delay(0.1).repeatForever(autoreverses: true)){
                                moveRightLeft.toggle()
                            }
                        }
                }
            } else {
                Text("*Nothing here...*")
                    .foregroundStyle(.secondary)                
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}
