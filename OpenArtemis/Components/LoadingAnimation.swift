//
//  LoadingAnimation.swift
//  OpenArtemis
//
//  Created by daniel on 02/12/23.
//

import SwiftUI

struct LoadingAnimation: View {
    var loadingText: String
    @State private var moveRightLeft = false
    let screenFrame = Color(.systemBackground)
    let isLoading: Bool
    var body: some View {
        ZStack{
            screenFrame
                .edgesIgnoringSafeArea(.all)
            
            VStack{
                if isLoading {
                    ZStack{
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
                    
                    Text(loadingText)
                        .font(.subheadline)
                        .italic()
                        .foregroundStyle(.secondary)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Color.red)

                    Text("No Results Found")
                        .font(.subheadline)
                        .italic()
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
