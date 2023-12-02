//
//  AppIconManager.swift
//  OpenArtemis
//
//  Created by daniel on 02/12/23.
//

import Foundation
import UIKit

class AppIconManager {
  private var appIcons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any] ?? [:]
  
  
  
  func setAppIcon(to iconName: String) {
    UIApplication.shared.setAlternateIconName(iconName == "AppIcon" ? "" : iconName) { error in
      if let error = error {
        print("Error setting alternate icon \(error.localizedDescription)")
      }
      
    }
  }
  
  func getIcons() -> [String] {
    var alternateIconNames: [String] = []
    
    if let icons = appIcons["CFBundleAlternateIcons"] as? [String: Any] {
      for (iconNameString, _) in icons{
          alternateIconNames.append(iconNameString)
      }
    }
    return alternateIconNames
  }

  
  func getCurrentIconName() -> String{
    return UIApplication.shared.alternateIconName ?? "AppIcon"
  }
  
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
