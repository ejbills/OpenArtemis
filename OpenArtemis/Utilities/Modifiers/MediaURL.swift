//
//  MediaURL.swift
//  OpenArtemis
//
//  Created by daniel on 02/12/23.
//

import Foundation
extension URL {
  func isVideoMediaURL() -> Bool {
    let l = self.lastPathComponent
    return l.contains(".mp4") || l.contains(".gif")
}
}
