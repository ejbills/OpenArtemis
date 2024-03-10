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
    
    func setLoading(toState: Bool) {
        withAnimation {
            loading = toState
        }
    }
}
