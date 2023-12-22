//
//  ChristmasTree.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/21/23.
//

import SwiftUI

struct SwiftUIXmasTree2: View {
    
    @State private var isSpinning = false
    
    var body: some View {
        VStack {
            Image(systemName: "wand.and.stars.inverse")
                .font(.system(size: 64))
                .foregroundStyle(EllipticalGradient(
                    colors:[Color.red, Color.green],
                    center: .center,
                    startRadiusFraction: 0.0,
                    endRadiusFraction: 0.5))
                .hueRotation(.degrees(isSpinning ? 0 : 340))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false).delay(0.2), value: isSpinning)
            
            ZStack {
                ZStack {
                    Circle() // MARK: One. No delay
                        .stroke(lineWidth: 2)
                        .frame(width: 20, height: 20)
                    .foregroundColor(Color(#colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)))
                    
                    ForEach(0 ..< 4) {
                        Circle()
                            .foregroundColor(.red)
                            .hueRotation(.degrees(isSpinning ? Double($0) * 310 : Double($0) * 50))
                            .offset(y: -10)
                            .rotationEffect(.degrees(Double($0) * -90))
                            .rotationEffect(.degrees(isSpinning ? 0 : -180))
                            .frame(width: 4, height: 4)
                            .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: isSpinning)
                    }
                }
                .rotation3DEffect(.degrees(60), axis: (x: 1, y: 0, z: 0))
                .offset(y: -160)
                
                ZStack {
                    Circle() // MARK: Two. 0.1 delay
                        .stroke(lineWidth: 3)
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color(#colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)))
                    
                    ForEach(0 ..< 4) {
                        Circle()
                            .foregroundColor(.red)
                            .hueRotation(.degrees(isSpinning ? Double($0) * 310 : Double($0) * 50))
                            .offset(y: -25)
                            .rotationEffect(.degrees(Double($0) * -90))
                            .rotationEffect(.degrees(isSpinning ? 0 : -180))
                            .frame(width: 6, height: 6)
                            .animation(.linear(duration: 1.5).repeatForever(autoreverses: false).delay(0.1), value: isSpinning)
                    }
                }
                .rotation3DEffect(.degrees(60), axis: (x: 1, y: 0, z: 0))
                .offset(y: -120)
                
                ZStack {
                    Circle() // Three. 0.2 delay
                        .stroke(lineWidth: 4)
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color(#colorLiteral(red: 0.8321695924, green: 0.985483706, blue: 0.4733308554, alpha: 1)))
                    
                    ForEach(0 ..< 4) {
                        Circle()
                            .foregroundColor(.red)
                            .hueRotation(.degrees(isSpinning ? Double($0) * 310 : Double($0) * 50))
                            .offset(y: -40)
                            .rotationEffect(.degrees(Double($0) * -90))
                            .rotationEffect(.degrees(isSpinning ? 0 : -180))
                            .frame(width: 8, height: 8)
                            .animation(.linear(duration: 1.5).repeatForever(autoreverses: false).delay(0.2), value: isSpinning)
                    }
                }
                .rotation3DEffect(.degrees(60), axis: (x: 1, y: 0, z: 0))
                .offset(y: -80)
                
                ZStack {
                    Circle() // MARK: Four. 0.3 delay
                        .stroke(lineWidth: 4)
                        .frame(width: 110, height: 110)
                    .foregroundColor(Color(#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)))
                    
                    ForEach(0 ..< 4) {
                        Circle()
                            .foregroundColor(.red)
                            .hueRotation(.degrees(isSpinning ? Double($0) * 310 : Double($0) * 50))
                            .offset(y: -55)
                            .rotationEffect(.degrees(Double($0) * -90))
                            .rotationEffect(.degrees(isSpinning ? 0 : -180))
                            .frame(width: 8, height: 8)
                            .animation(.linear(duration: 1.5).repeatForever(autoreverses: false).delay(0.3), value: isSpinning)
                    }
                }
                .rotation3DEffect(.degrees(60), axis: (x: 1, y: 0, z: 0))
                .offset(y: -40)
                
                ZStack {
                    Circle() // MARK: Five. 0.4 delay
                        .stroke(lineWidth: 4)
                        .frame(width: 140, height: 140)
                        .foregroundColor(Color(#colorLiteral(red: 0.4508578777, green: 0.9882974029, blue: 0.8376303315, alpha: 1)))
                    
                    ForEach(0 ..< 4) {
                        Circle()
                            .foregroundColor(.red)
                            .hueRotation(.degrees(isSpinning ? Double($0) * 310 : Double($0) * 50))
                            .offset(y: -70)
                            .rotationEffect(.degrees(Double($0) * -90))
                            .rotationEffect(.degrees(isSpinning ? 0 : -180))
                            .frame(width: 10, height: 10)
                            .animation(.linear(duration: 1.5).repeatForever(autoreverses: false).delay(0.4), value: isSpinning)
                    }
                }
                .rotation3DEffect(.degrees(60), axis: (x: 1, y: 0, z: 0))
                .offset(y: 0)
                
                ZStack {
                    Circle() // MARK: Six. 0.5 delay
                        .stroke(lineWidth: 3)
                        .frame(width: 170, height: 170)
                    .foregroundColor(Color(#colorLiteral(red: 0.4620226622, green: 0.8382837176, blue: 1, alpha: 1)))
                    
                    ForEach(0 ..< 4) {
                        Circle()
                            .foregroundColor(.red)
                            .hueRotation(.degrees(isSpinning ? Double($0) * 310 : Double($0) * 50))
                            .offset(y: -85)
                            .rotationEffect(.degrees(Double($0) * -90))
                            .rotationEffect(.degrees(isSpinning ? 0 : -180))
                            .frame(width: 8, height: 8)
                            .animation(.linear(duration: 1.5).repeatForever(autoreverses: false).delay(0.5), value: isSpinning)
                    }
                }
                .rotation3DEffect(.degrees(60), axis: (x: 1, y: 0, z: 0))
                .offset(y: 40)
                
                ZStack {
                    Circle() // MARK: Seven. 0.6 delay
                        .stroke(lineWidth: 5)
                        .frame(width: 200, height: 200)
                        .foregroundColor(Color(#colorLiteral(red: 0.476841867, green: 0.5048075914, blue: 1, alpha: 1)))
                    
                    ForEach(0 ..< 4) {
                        Image(systemName: "star")
                            .foregroundColor(.red)
                            .hueRotation(.degrees(isSpinning ? Double($0) * 310 : Double($0) * 50))
                            .offset(y: -100)
                            .rotationEffect(.degrees(Double($0) * -90))
                            .rotationEffect(.degrees(isSpinning ? 0 : -180))
                            .animation(.linear(duration: 1.5).repeatForever(autoreverses: false).delay(0.6), value: isSpinning)
                    }
                }
                .rotation3DEffect(.degrees(60), axis: (x: 1, y: 0, z: 0))
                .offset(y: 80)
                
                ZStack {
                    Circle() // MARK: Eight. 0.7 delay
                        .stroke(lineWidth: 4)
                        .frame(width: 230, height: 230)
                        .foregroundColor(Color(#colorLiteral(red: 0.8446564078, green: 0.5145705342, blue: 1, alpha: 1)))
                    
                    ForEach(0 ..< 4) {
                        Circle()
                            .foregroundColor(.red)
                            .hueRotation(.degrees(isSpinning ? Double($0) * 310 : Double($0) * 50))
                            .offset(y: -115)
                            .rotationEffect(.degrees(Double($0) * -90))
                            .rotationEffect(.degrees(isSpinning ? 0 : -180))
                            .frame(width: 10, height: 10)
                            .animation(.linear(duration: 1.5).repeatForever(autoreverses: false).delay(0.7), value: isSpinning)
                    }
                }
                .rotation3DEffect(.degrees(60), axis: (x: 1, y: 0, z: 0))
                .offset(y: 120)
                
                ZStack {
                    Circle() // MARK: Nine. 0.8 delay
                        .stroke(lineWidth: 5)
                        .frame(width: 260, height: 260)
                        .foregroundColor(Color(#colorLiteral(red: 0.5738074183, green: 0.5655357838, blue: 0, alpha: 1)))
                    
                    ForEach(0 ..< 4) {
                        Circle()
                            .foregroundColor(.red)
                            .hueRotation(.degrees(isSpinning ? Double($0) * 310 : Double($0) * 50))
                            .offset(y: -130)
                            .rotationEffect(.degrees(Double($0) * -90))
                            .rotationEffect(.degrees(isSpinning ? 0 : -180))
                            .frame(width: 12, height: 12)
                            .animation(.linear(duration: 1.5).repeatForever(autoreverses: false).delay(0.8), value: isSpinning)
                    }
                }
                .rotation3DEffect(.degrees(60), axis: (x: 1, y: 0, z: 0))
                .offset(y: 160)
                
                
                ZStack {
                    Circle() // MARK: Ten. 0.9 delay
                        .stroke(lineWidth: 5)
                        .foregroundColor(Color(#colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1)))
                    
                    ForEach(0 ..< 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.red)
                            .hueRotation(.degrees(isSpinning ? Double($0) * 310 : Double($0) * 50))
                            .offset(y: -145)
                            .rotationEffect(.degrees(Double($0) * -90))
                            .rotationEffect(.degrees(isSpinning ? 0 : -180))
                            .animation(.linear(duration: 1.5).repeatForever(autoreverses: false).delay(0.9), value: isSpinning)
                    }
                }
                .frame(width: 290, height: 290)
                .rotation3DEffect(.degrees(60), axis: (x: 1, y: 0, z: 0))
                .offset(y: 200)
            }
            .onAppear() {
                isSpinning.toggle()
            }
        }
    }
}
