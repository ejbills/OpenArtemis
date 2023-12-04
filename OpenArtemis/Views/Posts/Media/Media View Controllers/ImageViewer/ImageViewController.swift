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
                                                        ImageView(images: images, imageTitle: imageTitle, rootViewClosure: dismissMedia)
        )
        hostingController.modalPresentationStyle = .fullScreen
        hostingController.modalTransitionStyle = .crossDissolve
        rootView.present(hostingController, animated: true, completion: nil)
    }
    
    private func dismissMedia() {
        guard let rootView = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        
        rootView.dismiss(animated: true)
    }
}


private struct ImageView: View {
    var images: [String]
    var imageTitle: String?
    @State private var isZoomed: Bool = false
    @State private var offset: CGSize = .zero
    @State private var showOverlay: Bool = true
    @State private var arrayIndex: (Int, Int) = (0, 0)
    @State private var scrollPosition: Int?

    var rootViewClosure: (() -> ())?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: images.count > 1) {
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
            withAnimation {
                showOverlay.toggle()
            }
        }
        .onChange(of: scrollPosition) { oldPos, newPos in
            if let newPos = newPos {
                arrayIndex = (newPos, images.count)
            }
        }
        .scrollDisabled(isZoomed)
        .ignoresSafeArea(.all)
        .scrollTargetBehavior(.paging)
        .statusBar(hidden: true)
        .onAppear {
            //reinitialize this
            arrayIndex = (0, images.count)
        }
        .gesture(
            SimultaneousGesture(
                // swipe to next pic
                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                    .onEnded { value in
                        if images.count > 1 {
                            if value.translation.height > 100 {
                                if let rootViewClosure = rootViewClosure {
                                    rootViewClosure()
                                }
                                
                                withAnimation(.snappy) {
                                    offset = .zero
                                }
                            } else {
                                withAnimation(.interpolatingSpring(stiffness: 1000, damping: 100, initialVelocity: 0)) {
                                    offset = .zero
                                }
                            }
                        }
                    },
                // general drag behavior
                DragGesture()
                    .onChanged { value in
                        onDragChanged(value)
                    }
                    .onEnded { value in
                        onDragEnded(value)
                    }
            )
        )
        .offset(y: offset.height)
//        .overlay(ImageViewOverlay(title: imageTitle, arrayIndex: arrayIndex, opacity: showOverlay || !isZoomed ? 1 : 0))
        .onChange(of: isZoomed) { oldValue, newValue in
            if !newValue {
                // Reset offset when zoom is not active
                offset = .zero
            }
        }
    }

    private func onDragChanged(_ value: DragGesture.Value) {
        if value.translation.height > 0 && !isZoomed {
            // Only update the offset if dragging down and not zoomed
            withAnimation(.spring) {
                offset = CGSize(width: 0, height: value.translation.height)
            }
        }
    }

    private func onDragEnded(_ value: DragGesture.Value) {
        // Check if the drag has sufficient velocity and is in the downward direction
        let velocityThreshold: CGFloat = 150 // downward speed
        let angleThreshold: Double = 120 // max downward angle allowed for dismissal

        let angle = atan2(Double(value.translation.height), Double(value.translation.width))
        let angleDegrees = angle * (180.0 / .pi)
        
        if value.predictedEndTranslation.height > 80 && value.predictedEndTranslation.height > velocityThreshold && abs(angleDegrees) < angleThreshold && !isZoomed {
            dismissView()
        } else {
            withAnimation(.spring()) {
                // Snap back to the default location
                offset = .zero
            }
        }
    }

    private func dismissView() {
        if let rootViewClosure = rootViewClosure {
            rootViewClosure()
        }

        withAnimation(.spring()) {
            offset = .zero
        }
    }
}
