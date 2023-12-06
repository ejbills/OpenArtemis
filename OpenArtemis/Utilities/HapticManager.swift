//
//  HapticManager.swift
//  OpenArtemis
//
//  Created by daniel on 05/12/23.
//

import SwiftUI
import CoreHaptics

class HapticManager {
    static let shared = HapticManager()

    private init() {}
    
    func gentleInfo() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }

    func mushyInfo() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    func firmerInfo() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    func confirmationInfo() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
