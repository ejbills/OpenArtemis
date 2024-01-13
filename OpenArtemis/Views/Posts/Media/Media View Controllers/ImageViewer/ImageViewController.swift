//
//  ImageViewController.swift
//  OpenArtemis
//
//  Created by daniel on 04/12/23.
//
import SwiftUI
import VisionKit
import CachedImage
import LazyPager

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
                                                        ImageView(images: images, rootViewClosure: dismissMedia)
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
    var rootViewClosure: (() -> ())?
    
    @State private var offset: CGSize = .zero
    @State private var index: Int = 0
    
    var body: some View {
        LazyPager(data: images, page: $index) { url in
            let url = URL(string: url)
            
            CachedImage(
                url: url,
                content: { image in
                    LiveTextInteraction(image: image)
                        .scaledToFit()
                },
                placeholder: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            )
        }
        .zoomable(min: 1, max: 5)
        .onDismiss {
            dismissView()
        }
        .ignoresSafeArea()
        .overlay(
            images.count > 1 ?
            VanillaPageControl(numberOfPages: images.count, currentPage: $index)
                .padding(.bottom, 20)
                .allowsHitTesting(false) : nil,
            alignment: .bottom
        )
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

struct VanillaPageControl: UIViewRepresentable {
    var numberOfPages: Int
    @Binding var currentPage: Int

    func makeUIView(context: Context) -> UIPageControl {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = currentPage
        pageControl.addTarget(context.coordinator, action: #selector(Coordinator.updateCurrentPage(sender:)), for: .valueChanged)

        pageControl.pageIndicatorTintColor = UIColor.gray

        return pageControl
    }

    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: VanillaPageControl

        init(_ pageControl: VanillaPageControl) {
            self.parent = pageControl
        }

        @objc func updateCurrentPage(sender: UIPageControl) {
            parent.currentPage = sender.currentPage
        }
    }
}

