//
//  GlobalLoadingManager.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 3/10/24.
//

import SwiftUI
import Observation

@Observable class GlobalLoadingManager {
    static let shared = GlobalLoadingManager()
    var loading: Bool = false
    var failed: Bool = false
    
    func setLoading(toState: Bool) {
        DispatchQueue.main.async {
            withAnimation {
                self.loading = toState
            }
        }
    }
    
    func toastFailure() {
        withAnimation(.snappy) {
            self.failed = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut) {
                self.failed = false
            }
        }
    }
}
