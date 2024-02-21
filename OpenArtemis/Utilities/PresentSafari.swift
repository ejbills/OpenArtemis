//
//  PresentSafari.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/29/23.
//

import SwiftUI
import SafariServices
import Defaults

class SafariHelper {
    static func openSafariView(withURL url: URL, from viewController: UIViewController? = nil) {
        let presentingViewController = viewController ?? UIApplication.shared.windows.first?.rootViewController
        
        if let presentingViewController = presentingViewController {
            // Create a Safari view controller configuration object
            let configuration = SFSafariViewController.Configuration()
            configuration.entersReaderIfAvailable = Defaults[.readerMode]
            
            // Create a Safari view controller with the configuration
            let safariViewController = SFSafariViewController(url: url, configuration: configuration)
            
            // Present the Safari view controller
            presentingViewController.present(safariViewController, animated: true, completion: nil)
        }
    }
}
