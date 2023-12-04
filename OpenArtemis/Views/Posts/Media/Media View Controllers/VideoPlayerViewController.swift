//
//  VideoPlayerViewController.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/30/23.
//

import AVKit
import AVFoundation
import SwiftUI

struct VideoPlayerViewController: UIViewControllerRepresentable {
    var videoURL: URL
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.modalPresentationStyle = .fullScreen
        let player = AVPlayer(url: videoURL)
        controller.player = player
        
        // Set up notification for when the video playback ends
        // Shit doesnt work :(
        NotificationCenter.default.addObserver(forName: AVPlayerItem.failedToPlayToEndTimeNotification, object: player.currentItem, queue: .main) { _ in
            // Video playback ended, restore AVAudioSession to normal
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
        
        return controller
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject{
        var parent: VideoPlayerViewController
        
        init(_ parent: VideoPlayerViewController) {
            self.parent = parent
        }
    }
    
    
    
    
    func updateUIViewController(_ playerController: AVPlayerViewController, context: Context) {}
    
    func play() {
        let player = AVPlayer(url: videoURL)
        let controller = AVPlayerViewController()
        controller.player = player
        
        // Set AVAudioSession to duck others
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: .duckOthers)
        } catch {
            print("Failed to set AVAudioSession category: \(error)")
        }
        
        // Present the video player
        UIApplication.shared.windows.first?.rootViewController?.present(controller, animated: true) {
            controller.player?.play()
        }
    }
}

