//
//  ImageViewOverlay.swift
//  OpenArtemis
//
//  Created by daniel on 04/12/23.
//

import SwiftUI

struct ImageViewOverlay: View {
    var title: String? = nil
    @State var arrayIndex: (Int, Int)
    var opacity: CGFloat
    
    var body: some View {
        VStack(alignment: .leading){
            if let title {
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .allowsHitTesting(false)
            }
            
            Spacer()
            
            if arrayIndex.1 > 1 {
                Text("\(arrayIndex.0 + 1)/\(arrayIndex.1)")
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Capsule(style: .continuous).fill(.regularMaterial))
                    .frame(maxWidth: .infinity)
                    .allowsHitTesting(false)
            }
            
            HStack(spacing: 12) {
                
                Button {
                    
                } label: {
                    Label("Share Image", systemImage: "square.and.arrow.up")
                        .labelStyle(.iconOnly)
                        .font(.system(size: 24))
                }
                
                
                Button {
                    
                } label: {
                    Label("Download Image", systemImage: "square.and.arrow.down")
                        .labelStyle(.iconOnly)
                        .font(.system(size: 24))
                }
                
            }
            .compositingGroup()
            .frame(maxWidth: .infinity)
        }
        .multilineTextAlignment(.leading)
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.bottom, 32)
        .padding(.top, 64)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            VStack(spacing: 0) {
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.black.opacity(1), location: 0),
                            .init(color: Color.black.opacity(0), location: 1)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(height: 150)
                Spacer()
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.black.opacity(1), location: 0),
                            .init(color: Color.black.opacity(0), location: 1)
                        ]),
                        startPoint: .bottom,
                        endPoint: .top
                    ))
                    .frame(height: 150)
            }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(false)
        )
        .compositingGroup()
        .compositingGroup()
        .opacity(opacity)
        .allowsHitTesting(opacity != 0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
    }
}
