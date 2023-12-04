//
//  ImageViewer.swift
//  OpenArtemis
//
//  Created by daniel on 04/12/23.
//

import SwiftUI
import VisionKit
import CachedImage

struct ImageViewer: ViewModifier {
    @Binding var isPresented: Bool
    var images: [String]
    var title: String?
    @State private var offset: CGSize = .zero
    @State private var isZoomed: Bool = false
    @State private var showOverlay: Bool = true
    @State var scrollPosition: Int?
    @State var actualScrollPostion: Int = 0
    
    @State var arrayIndex: (Int, Int) = (0, 0)
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented, content: {
                ScrollView(.horizontal, showsIndicators: false){
                    LazyHStack(spacing: 0){
                        ForEach(images, id: \.self){imageURL in
                            ZoomableScrollView(isZoomed: $isZoomed){
                                CachedImage(
                                    url: URL(string: imageURL),
                                    content: { image in
       
                                        LiveTextInteraction(image: image)
                                            .scaledToFit()
                                            .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
                                    },
                                    placeholder: {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                            .animatedLoading()
                                    })
                            }
                            .frame(width: UIScreen.screenWidth)
                            .id(images.firstIndex(of: imageURL))
                        }
                    }
                    .scrollTargetLayout()
                }
                .onChange(of: scrollPosition){ pos in
                    arrayIndex = (pos!, images.count)
                }
                .scrollPosition(id: $scrollPosition)
                .scrollDisabled(isZoomed)
                .ignoresSafeArea(.all)
                .background(Color.black)
                .scrollTargetBehavior(.paging)
                .preferredColorScheme(.dark)
                .statusBar(hidden: true)
                .onAppear{
                    //reinitalize this
                    arrayIndex = (0, images.count)
                }
                .overlay(
                    Group {
                        ImageViewOverlay(title: title, arrayIndex: $arrayIndex, opacity: !showOverlay || isZoomed ? 0 : 1)
                    }
                )
                .highPriorityGesture(
                    TapGesture()
                        .onEnded{
                            withAnimation{
                                showOverlay.toggle()
                            }
                        }
                )
                .highPriorityGesture(
                    
                    DragGesture(minimumDistance: 20, coordinateSpace: .local)
                        .onEnded { value in
                            if value.translation.height > 100 {
                                withAnimation{
                                    isPresented = false
                                }
                                offset = .zero
                            }
                            else {
                                var transaction = Transaction()
                                transaction.isContinuous = true
                                transaction.animation = .interpolatingSpring(stiffness: 1000, damping: 100, initialVelocity: 0)
                                withTransaction(transaction){
                                    offset = .zero
                                }
                            }
                        }
                        .onChanged { value in
                            var transaction = Transaction()
                            transaction.isContinuous = true
                            transaction.animation = .interpolatingSpring(stiffness: 1000, damping: 100, initialVelocity: 0)
                            
                            if value.translation.height > 0 && max(value.translation.width, 10) <= 10 {
                                withTransaction(transaction){
                                    offset = value.translation
                                }
                            }
                        }
                )
                .offset(y: offset.height)
            })
            .onDisappear{
                isPresented = false
            }
    }
}

extension View {
    func imageViewer(isPresented: Binding<Bool>, _ images: [String], title: String? = nil) -> some View {
        modifier(ImageViewer(isPresented: isPresented, images: images, title: title))
    }
}
