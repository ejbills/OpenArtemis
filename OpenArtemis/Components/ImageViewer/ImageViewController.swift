//
//  ImageViewController.swift
//  OpenArtemis
//
//  Created by daniel on 04/12/23.
//
import SwiftUI
import VisionKit
import CachedImage

class ImageViewerController: UIViewController {
    @Published var images: [String]
    @Published var imageTitle: String?
    
    init(images: [String], imageTitle: String) {
        self.images = images
        self.imageTitle = imageTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func present() {
        guard let rootView = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        let hostingController = UIHostingController(rootView:
                                                        ImageViewView(images: images, imageTitle: imageTitle, rootView: rootView)
        )
        hostingController.modalPresentationStyle = .fullScreen
        hostingController.modalTransitionStyle = .crossDissolve
        rootView.present(hostingController, animated: true, completion: nil)
    }
    
    @objc private func closeButtonTapped() {
        guard let rootView = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        
        rootView.dismiss(animated: true, completion: nil)
    }
}


private struct ImageViewView: View {
    var images: [String]
    var imageTitle: String?
    @State var offset: CGSize = .zero
    @State var isZoomed: Bool = false
    @State var showOverlay: Bool = true
    @State var scrollPosition: Int?
    @State var arrayIndex: (Int, Int) = (0, 0)
    
    var rootView: UIViewController
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(images, id: \.self) { imageURL in
                    ZoomableScrollView(isZoomed: isZoomed) {
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
        .onTapGesture {
            withAnimation{
                showOverlay.toggle()
            }
        }
        .onChange(of: scrollPosition) { oldPost, newPos in
            arrayIndex = (newPos!, images.count)
        }
        .scrollDisabled(isZoomed)
        .ignoresSafeArea(.all)
        .scrollTargetBehavior(.paging)
        .statusBar(hidden: true)
        .onAppear {
            //reinitialize this
            arrayIndex = (0, images.count)
        }
        .highPriorityGesture(
            
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .onEnded { value in
                    if value.translation.height > 100 {
                        withAnimation{
                            rootView.dismiss(animated: true, completion: nil)
                        }
                        offset = .zero
                    }
                    else {
                        var transaction = Transaction()
                        transaction.isContinuous = true
                        transaction.animation = .interpolatingSpring(stiffness: 1000, damping: 100, initialVelocity: 0) //needed for it to not be janky
                        withTransaction(transaction){
                            offset = .zero
                        }
                    }
                }
                .onChanged { value in
                    var transaction = Transaction()
                    transaction.isContinuous = true
                    transaction.animation = .interpolatingSpring(stiffness: 1000, damping: 100, initialVelocity: 0) //needed for it to not be janky
                    
                    if value.translation.height > 0 && max(value.translation.width, 10) <= 10 {
                        withTransaction(transaction){
                            offset = value.translation
                        }
                    }
                }
        )
        .offset(y: offset.height)
//        .overlay(ImageViewOverlay(title: imageTitle,arrayIndex: arrayIndex, opacity: showOverlay || !isZoomed ? 1 : 0))
    }
}
