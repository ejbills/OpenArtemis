//
//  PresentSafari.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/29/23.
//

import SwiftUI
import SafariServices

class SafariHelper {
    static func openSafariView(withURL url: URL, from viewController: UIViewController? = nil) {
        let presentingViewController = viewController ?? UIApplication.shared.windows.first?.rootViewController

        if let presentingViewController = presentingViewController {
            presentingViewController.present(SFSafariViewController(url: url), animated: true, completion: nil)
        }
    }
}
