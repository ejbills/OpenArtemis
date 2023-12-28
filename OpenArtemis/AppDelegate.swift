//
//  AppDelegate.swift
//  OpenArtemis
//
//  Created by daniel on 02/12/23.
//

import AVFAudio
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])

        return true
    }
}
