//
//  PrivacyTests.swift
//  OpenArtemisTests
//
//  Created by daniel on 02/12/23.
//

import XCTest
@testable import OpenArtemis

final class PrivacyTests: XCTestCase {
    
    
    
    func testURLRewrite() throws {
        let urls = [
            "twitter.com",
            "x.com",
            "youtu.be/1234",
            "www.youtube.com",
            "youtube.com",
            "i.imgur.com/duwawdfd.gifv",
            "medium.com"
        ]
        
        let results = [
            "nitter.net",
            "nitter.net",
            "yewtu.be/watch?v=1234",
            "yewtu.be",
            "yewtu.be",
            "rimgo.lunar.icu/duwawdfd.mp4",
            "scribe.rip"
        ]
        
        var index = 0
        for url in urls {
            XCTAssertEqual(url.privacyURL().privateURL, results[index])
            index += 1
        }
    }
    
    
    //  func testRemoveTrackingParams() throws {
    //    let remover = TrackingParamRemover()
    //    let dirty = URL(string: "https://example.org/?utm_source=news_page&utm_campaign=promo&utm_medium=link")!
    //    let clean = "https://example.org"
    //    print(remover.cleanURL(dirty).absoluteString)
    //    XCTAssertEqual(clean, remover.cleanURL(dirty).absoluteString)
    //  }
}
