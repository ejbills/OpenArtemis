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
    private var images: [String]
    private var imageTitle: String? = ""
    @State private var offset: CGSize = .zero
    private var isZoomed: Bool = false
    @State private var showOverlay: Bool = true
    private var scrollPosition: Int?
    @State private var arrayIndex: (Int, Int) = (0, 0)
    init(images: [String], imageTitle: String) {
        self.images = images
        self.imageTitle = imageTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func present() {
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        let hostingController = UIHostingController(
            rootView:
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 0) {
                        ForEach(images, id: \.self) { imageURL in
                            ZoomableScrollView(isZoomed: self.isZoomed) {
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
                            .id(self.images.firstIndex(of: imageURL))
                        }
                    }
                    .scrollTargetLayout()
                }
                .onChange(of: scrollPosition) { oldPost, newPos in
                    self.arrayIndex = (newPos!, self.images.count)
                }
                .scrollDisabled(isZoomed)
                .ignoresSafeArea(.all)
                .background(Color.black)
                .scrollTargetBehavior(.paging)
                .preferredColorScheme(.dark)
                .overlay(ImageViewOverlay(title: imageTitle,arrayIndex: self.arrayIndex, opacity: self.showOverlay || !self.isZoomed ? 1 : 0))
                .highPriorityGesture(
                    TapGesture()
                        .onEnded{
                            withAnimation{
                                self.showOverlay.toggle()
                            }
                        }
                )
                .statusBar(hidden: true)
                .onAppear {
                    //reinitialize this
                    self.arrayIndex = (0, self.images.count)
                }
                .highPriorityGesture(
                    
                    DragGesture(minimumDistance: 20, coordinateSpace: .local)
                        .onEnded { value in
                            if value.translation.height > 100 {
                                withAnimation{
                                    self.closeButtonTapped()
                                }
                                self.offset = .zero
                            }
                            else {
                                var transaction = Transaction()
                                transaction.isContinuous = true
                                transaction.animation = .interpolatingSpring(stiffness: 1000, damping: 100, initialVelocity: 0) //needed for it to not be janky
                                withTransaction(transaction){
                                    self.offset = .zero
                                }
                            }
                        }
                        .onChanged { value in
                            var transaction = Transaction()
                            transaction.isContinuous = true
                            transaction.animation = .interpolatingSpring(stiffness: 1000, damping: 100, initialVelocity: 0) //needed for it to not be janky
                            
                            if value.translation.height > 0 && max(value.translation.width, 10) <= 10 {
                                withTransaction(transaction){
                                    self.offset = value.translation
                                }
                            }
                        }
                )
                .offset(y: offset.height)
            
        )
        
        hostingController.modalPresentationStyle = .fullScreen
        
        guard let rootView = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        
        rootView.present(hostingController, animated: true, completion: nil)
    }
    
    @objc private func closeButtonTapped() {
        guard let rootView = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        
        rootView.dismiss(animated: true, completion: nil)
    }
}
