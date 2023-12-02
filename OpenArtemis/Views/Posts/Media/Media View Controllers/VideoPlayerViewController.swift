//
//  VideoPlayerViewController.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/30/23.
//

import AVKit
import SwiftUI

struct VideoPlayerViewController: UIViewControllerRepresentable {
    var videoURL: URL

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.modalPresentationStyle = .fullScreen
        let player = AVPlayer(url: videoURL)
        controller.player = player
        controller.player?.play()

        return controller
    }

    func updateUIViewController(_ playerController: AVPlayerViewController, context: Context) {}

    func play() {
        print(videoURL)
      let player = AVPlayer(url: videoURL)
        let controller = AVPlayerViewController()
        controller.player = player
        UIApplication.shared.windows.first?.rootViewController?.present(controller, animated: true) {
            controller.player?.play()
        }
    }
}
