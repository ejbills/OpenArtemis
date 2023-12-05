//
//  AppDelegate.swift
//  OpenArtemis
//
//  Created by daniel on 02/12/23.
//

import Foundation
import UIKit
import WebKit
import AVFAudio

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
        return true
    }
    
}
