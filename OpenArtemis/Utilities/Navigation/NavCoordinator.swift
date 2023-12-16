//
//  NavCoordinator.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/1/23.
//

import SwiftUI

class NavCoordinator: ObservableObject {
    @Published var path = NavigationPath()
}

struct NavigationStackWrapper<Content: View>: View {
    @StateObject private var tabCoordinator: NavCoordinator
    var content: () -> Content
    
    init(tabCoordinator: NavCoordinator, @ViewBuilder content: @escaping () -> Content) {
        self._tabCoordinator = StateObject(wrappedValue: tabCoordinator)
        self.content = content
    }
    
    var body: some View {
        NavigationStack(path: $tabCoordinator.path) {
            content()
                .handleDeepLinkViews()
        }
        .handleDeepLinkResolution()
        .environmentObject(tabCoordinator)
        
    }
}
