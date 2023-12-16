//
//  AppDelegate.swift
//  OpenArtemis
//
//  Created by daniel on 02/12/23.
//

import UIKit
import AVFAudio

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
        
        // Set navigation bar appearance
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithOpaqueBackground()
////        appearance.backgroundColor = UIColor(Color.themeBackgroundColor)
//        UINavigationBar.appearance().standardAppearance = appearance
//        UINavigationBar.appearance().scrollEdgeAppearance = appearance
//        
//        // Set tab bar appearance
//        let tabBarAppearance = UITabBarAppearance()
//        tabBarAppearance.configureWithOpaqueBackground()
////        tabBarAppearance.backgroundColor = UIColor(Color.themeBackgroundColor)
//        UITabBar.appearance().standardAppearance = tabBarAppearance
//        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        return true
    }
    
}
