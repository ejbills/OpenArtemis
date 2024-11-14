//
//  AppIconManager.swift
//  OpenArtemis
//
//  Created by daniel on 02/12/23.
//

import Foundation
import UIKit

let defaultIcon: String = "AppIcon"

/// This class lets you ,anage the apps icon
class AppIconManager {
    private var appIcons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any] ?? [:]
    
    
    ///Set the App Icon to a named String
    func setAppIcon(to iconName: String) {
        UIApplication.shared.setAlternateIconName(iconName == defaultIcon ? nil : iconName) { error in
            if let error = error {
                print("Error setting alternate icon \(error.localizedDescription)")
            }
            
        }
    }
    
    ///Returns an array of names for all the alternative app icons
    ///Note: The default one is not included but it should be accessible under the name "AppIcon"
    func getIcons() -> [String] {
        var alternateIconNames: [String] = []
        
        if let icons = appIcons["CFBundleAlternateIcons"] as? [String: Any] {
            for (iconNameString, _) in icons{
                alternateIconNames.append(iconNameString)
            }
        }
        return alternateIconNames
    }
    
    ///Returns the name of the currently applied icon
    func getCurrentIconName() -> String{
        return UIApplication.shared.alternateIconName ?? defaultIcon
    }
    
    ///Same as setAppIcon but uses private API to circumvent the alert popup that normally occurs
    func setAppIconWithoutAlert(to iconName: String?) {
        if UIApplication.shared.responds(to: #selector(getter: UIApplication.supportsAlternateIcons)) && UIApplication.shared.supportsAlternateIcons { // Mark 1
            
            typealias setAlternateIconNameClosure = @convention(c) (NSObject, Selector, NSString?, @escaping (NSError) -> ()) -> () // Mark 2.
            
            let selectorString = "_setAlternateIconName:completionHandler:" // Mark 3
            
            let selector = NSSelectorFromString(selectorString) // Mark 3
            let imp = UIApplication.shared.method(for: selector) // Mark 4
            let method = unsafeBitCast(imp, to: setAlternateIconNameClosure.self) // Mark 5
            method(UIApplication.shared, selector, iconName as NSString?, { _ in }) // Mark 6
        }
    }
}
