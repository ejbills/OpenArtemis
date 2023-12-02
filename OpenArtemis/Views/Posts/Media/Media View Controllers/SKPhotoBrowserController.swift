//
//  SKPhotoBrowserController.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/30/23.
//

import SwiftUI
import SKPhotoBrowser

class SKPhotoBrowserContainer: ObservableObject {
    @Published var browser: SKPhotoBrowser?

    init(images: [String]) {
        let skImages = images.map { SKPhoto.photoWithImageURL($0) }
        let browser = SKPhotoBrowser(photos: skImages)
        browser.initializePageIndex(0)
        self.browser = browser
    }
}

struct SKPhotoBrowserController: UIViewControllerRepresentable {
    @ObservedObject var container: SKPhotoBrowserContainer

    init(images: [String]) {
        self.container = SKPhotoBrowserContainer(images: images)
    }

    func makeUIViewController(context: Context) -> SKPhotoBrowser {
        guard let browser = container.browser else {
            fatalError("SKPhotoBrowser is nil.")
        }
        return browser
    }

    func updateUIViewController(_ uiViewController: SKPhotoBrowser, context: Context) {}

    func present() {
        guard let browser = container.browser else { return }
        UIApplication.shared.windows.first?.rootViewController?.present(browser, animated: true, completion: nil)
    }
}

