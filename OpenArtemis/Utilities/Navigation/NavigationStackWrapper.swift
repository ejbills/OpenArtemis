//
//  FullSwipeNavigationStack.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/22/23.
//  I DID NOT MAKE THIS. I GOT IT FROM THIS VIDEO: https://www.youtube.com/watch?v=4ceKPSTlL4I

import SwiftUI
import Defaults

struct NavigationStackWrapper<Content: View>: View {
    @StateObject private var tabCoordinator: NavCoordinator
    @Default(.swipeAnywhere) var swipeAnywhere
    var content: () -> Content
    let shouldRespondToGlobalLinking: Bool
    
    @State private var swipeGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer()
        gesture.name = UUID().uuidString
        gesture.isEnabled = false
        return gesture
    }()
    init(tabCoordinator: NavCoordinator, @ViewBuilder content: @escaping () -> Content, shouldRespondToGlobalLinking: Bool) {
        self._tabCoordinator = StateObject(wrappedValue: tabCoordinator)
        self.content = content
        self.shouldRespondToGlobalLinking = shouldRespondToGlobalLinking
    }
    
    var body: some View {
        NavigationStack(path: $tabCoordinator.path) {
            content()
                .handleDeepLinkViews()
                .background {
                    AttachGestureView(gesture: $swipeGesture, navigationDepth: tabCoordinator.path.count)
                }
        }
        .enabledFullSwipePop(swipeAnywhere)
        .handleDeepLinkResolution(shouldRespondToGlobalLinking: shouldRespondToGlobalLinking)
        .environmentObject(tabCoordinator)
        .environment(\.popGestureID, swipeGesture.name)
        .onReceive(NotificationCenter.default.publisher(for: .init(swipeGesture.name ?? "")), perform: { info in
            if let userInfo = info.userInfo, let status = userInfo["status"] as? Bool {
                swipeGesture.isEnabled = status
            }
        })
        
    }
}

struct NavigationSplitViewWrapper<Sidebar: View, Content: View>: View {
    @StateObject private var tabCoordinator: NavCoordinator
    var sidebar: () -> Sidebar
    var detail: () -> Content
    let shouldRespondToGlobalLinking: Bool
    
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    init(tabCoordinator: NavCoordinator, @ViewBuilder sidebar: @escaping () -> Sidebar, @ViewBuilder detail: @escaping () -> Content, shouldRespondToGlobalLinking: Bool) {
        self._tabCoordinator = StateObject(wrappedValue: tabCoordinator)
        self.sidebar = sidebar
        self.detail = detail
        self.shouldRespondToGlobalLinking = shouldRespondToGlobalLinking
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebar()
                .handleDeepLinkViews()
            
        } content: {
            detail()
        } detail: {
            NavigationStack(path: $tabCoordinator.path) {
                detail()
                    .handleDeepLinkViews()
            }
        }
        .handleDeepLinkResolution(shouldRespondToGlobalLinking: shouldRespondToGlobalLinking)
        .environmentObject(tabCoordinator)
    }
}

fileprivate struct PopNotificationID: EnvironmentKey {
    static var defaultValue: String?
}

fileprivate extension EnvironmentValues {
    var popGestureID: String? {
        get {
            self[PopNotificationID.self]
        }
        
        set {
            self[PopNotificationID.self] = newValue
        }
    }
}

extension View {
    @ViewBuilder
    func enabledFullSwipePop(_ isEnabled: Bool) -> some View {
        self
            .modifier(FullSwipeModifier(isEnabled: isEnabled))
    }
}

fileprivate struct FullSwipeModifier: ViewModifier {
    var isEnabled: Bool
    @Environment(\.popGestureID) private var gestureID
    func body(content: Content) -> some View {
        content
            .onChange(of: isEnabled, initial: true) { _, new in
                guard let gestureID = gestureID else { return }
                NotificationCenter.default.post(name: .init(gestureID), object: nil, userInfo: [
                    "status": new
                ])
            }
            .onDisappear {
                guard let gestureID = gestureID else { return }
                NotificationCenter.default.post(name: .init(gestureID), object: nil, userInfo: [
                    "status": false
                ])
            }
    }
}

fileprivate struct AttachGestureView: UIViewRepresentable {
    @Binding var gesture: UIPanGestureRecognizer
    let navigationDepth: Int
    
    func makeUIView(context: Context) -> some UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.async {
            if let parentViewController = uiView.parentViewController {
                if let navigationController = parentViewController.navigationController {
                    // Check if the navigation stack has more than one view controller
                    if self.navigationDepth > 0 {
                        if let _ = navigationController.view.gestureRecognizers?.first(where: { $0.name == self.gesture.name }) {
                            print("Already attached")
                        } else {
                            navigationController.addFullSwipeGesture(self.gesture)
                            print("Attached")
                        }
                    } else {
                        // Remove the gesture if the navigation stack count is below the threshold
                        if let existingGesture = navigationController.view.gestureRecognizers?.first(where: { $0.name == self.gesture.name }) {
                            navigationController.view.removeGestureRecognizer(existingGesture)
                            print("Detached")
                        }
                    }
                }
            }
        }
    }
}

fileprivate extension UINavigationController {
    func addFullSwipeGesture(_ gesture: UIPanGestureRecognizer) {
        guard let gestureSelector = interactivePopGestureRecognizer?.value(forKey: "targets") else { return }
        
        gesture.setValue(gestureSelector, forKey: "targets")
        view.addGestureRecognizer(gesture)
    }
}

fileprivate extension UIView {
    var parentViewController: UIViewController? {
        sequence(first: self) {
            $0.next
        }.first(where: { $0 is UIViewController }) as? UIViewController
    }
}
