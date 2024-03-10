//
//  GlobalLoadingManager.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 3/10/24.
//

import Foundation
import Observation

@Observable class GlobalLoadingManager {
    static let shared = GlobalLoadingManager()
    var loading: Bool = false
}
