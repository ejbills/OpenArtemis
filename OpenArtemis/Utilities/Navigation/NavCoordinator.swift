//
//  NavCoordinator.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/1/23.
//

import SwiftUI

class NavCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    
    func navToAndStore(forData: NavigationPayload) {
        switch forData {
        case .subredditFeed(let subredditFeedResponse):
            self.path.append(subredditFeedResponse)
        case .profile(let profileResponse):
            self.path.append(profileResponse)
        case .post(let postResponse):
            self.path.append(postResponse)
        }
        
        GlobalNavForwardManager.shared.storeNav(forData: forData, withCoordinator: self)
    }
    
}
