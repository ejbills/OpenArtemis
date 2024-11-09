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
                                                        ImageView(images: images, rootViewClosure: dismissMedia, title: imageTitle ?? nil)
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
    var title: String?
    
    @State private var offset: CGSize = .zero
    @State private var index: Int = 0
    @State private var currImg: Image? = nil
    @State private var hideOverlay: Bool = false
    
    var body: some View {
        ZStack {
            Color.black
            
            // A hidden button to allow using the escape button to hide this, works on iPads with keyboards and mac os
            Button(action: {
                dismissView()
            }) {
                // no view
            }
            .hidden()
            .keyboardShortcut(.cancelAction)
            
            LazyPager(data: images, page: $index) { url in
                let url = URL(string: url)
                
                CachedImage(
                    url: url,
                    content: { image in
//                        UIImageView()

                        LiveTextInteraction(image: image)
//                            .scaledToFit() // not scaling correctly on maca
//                            .scaledToFill()
                            .onAppear {
                                currImg = image
                            }
                    },
                    placeholder: {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                )
                .onChange(of: index) { _, newIndex in
                    if let imageURL = URL(string: images[newIndex]) {
                        loadImage(from: imageURL) { image in
                            if let image = image {
                                currImg = image
                            }
                        }
                    }
                }
            }
            .zoomable(min: 1, max: 5)
            .onDismiss {
                dismissView()
            }
            .ignoresSafeArea()
            .overlay(
                images.count > 1 && !hideOverlay ?
                VanillaPageControl(numberOfPages: images.count, currentPage: $index)
                    .padding(.bottom, 20)
                    .allowsHitTesting(false) : nil,
                alignment: .bottom
            )
//            .overlay(alignment: .topLeading) {
//                figure out how to properly display the title text
//                GeometryReader { geometry in
//                    if let title = title, !hideOverlay {
//                        Text(title)
//                            .padding(.top, geometry.safeAreaInsets.top +  16)
//                    }
//                }
//            }
            .overlay(alignment: .bottomLeading) {
                if let image = currImg, !hideOverlay {
                    ShareLink(item: image,
                              preview: SharePreview(
                                "",
                                image: image
                              ),
                              label: {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color.artemisAccent)
                            .frame(width: 25, height: 25)
                            .padding()
                    }
                    )
                    .padding()
                }
            }
        }
        .onTapGesture {
            withAnimation {
                hideOverlay.toggle()
            }
        }
        .ignoresSafeArea()
    }
    
    private func dismissView() {
        if let rootViewClosure = rootViewClosure {
            rootViewClosure()
        }
        
        withAnimation(.spring()) {
            offset = .zero
        }
    }
    
    private func loadImage(from url: URL, completion: @escaping (Image?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error loading image from URL: \(error)")
                    completion(nil)
                    return
                }

                guard let data = data, let uiImage = UIImage(data: data) else {
                    completion(nil)
                    return
                }

                let image = Image(uiImage: uiImage)
                completion(image)
            }
        }.resume()
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

