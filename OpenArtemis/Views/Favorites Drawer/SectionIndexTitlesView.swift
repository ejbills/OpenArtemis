//
//  SectionIndexTitlesView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/2/23.
//

import SwiftUI

struct SectionIndexTitlesView: View {
    let proxy: ScrollViewProxy
    let availChars: [String]

    @GestureState private var dragLocation: CGPoint = .zero
    @State private var lastSelectedLabel: String = ""

    var body: some View {
        VStack {
            ForEach(availChars, id: \.self) { letter in
                Text(letter)
                    .fontWeight(.medium)
                    .font(.system(size: 15))
                    .frame(width: 25)
                    .offset(
                        x: letter == lastSelectedLabel ? -50 : 0
                    )
                    .background(dragObserver(label: letter))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 6)
                .foregroundStyle(tagBgColor)
        )
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .updating($dragLocation) { value, state, _ in
                    state = value.location
                }
                .onEnded { value in
                    withAnimation(.snappy(duration: 0.15)) {
                        lastSelectedLabel = ""
                    }
                }
        )
    }

    func dragObserver(label: String) -> some View {
        GeometryReader { geometry in
            dragObserver(geometry: geometry, label: label)
        }
    }

    func dragObserver(geometry: GeometryProxy, label: String) -> some View {
        if geometry.frame(in: .global).contains(dragLocation) {
            if label != lastSelectedLabel {
                DispatchQueue.main.async {
                    withAnimation(.snappy(duration: 0.15)) {
                        lastSelectedLabel = label
                        HapticManager.shared.singleClick()
                    }
                    
                    proxy.scrollTo(label, anchor: .center)
                }
            }
        }
        return Rectangle().fill(Color.clear)
    }
}
