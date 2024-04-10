//
//  GlobalNavForwardManager.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 3/13/24.
//

import SwiftUI
import Observation

@Observable class GlobalNavForwardManager {
    static let shared = GlobalNavForwardManager()
    var data: NavigationPayload? = nil
    var coordinator: NavCoordinator? = nil
    
    var toastButton: Bool = false
    
    // nav setter
    func storeNav(forData: NavigationPayload, withCoordinator: NavCoordinator) {
        self.data = forData
        self.coordinator = withCoordinator
    }
    
    // nav getter
    func returnPrevNav() {
        if let navData = self.data, let navCoordinator = self.coordinator {
            self.data = nil
            self.coordinator = nil
            self.toastButton = false
            
            navCoordinator.navToAndStore(forData: navData)
        }
    }
}
