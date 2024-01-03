//
//  PrivacyURL.swift
//  OpenArtemis
//
//  Created by daniel on 02/12/23.
//

import Foundation
import Defaults

private func transformedURL(_ url: String, trackingParamRemover: TrackingParamRemover? = nil) -> Post.PrivateURL {
    @Default(.redirectToPrivateSites) var redirectToPrivateSites
    
    @Default(.youtubeRedirect) var youtubeRedirect
    @Default(.twitterRedirect) var twitterRedirect
    @Default(.mediumRedirect) var mediumRedirect
    @Default(.imgurRedirect) var imgurRedirect
    
    var privateURL: String = url
    var dirtyURL: String = url
    // This matches all the urls that we want to replace and changes them to the private one
    if redirectToPrivateSites {
        switch url {
            
            //TwitterA
        //TODO: Use the regex (\.|\/)twitter\.com instead of just finding any x.com link
        case let str where str.contains(try! Regex("(.|/)twitter.com")):
            privateURL = str.replacingOccurrences(of: "twitter.com", with: twitterRedirect == "" ? "twitter.com" : twitterRedirect) //Instance located in the Netherlands
            conditionalIncreaseStats()
        //TODO: Use the regex (\.|\/)x\.com instead of just finding any x.com link
        case let str where str.contains(try! Regex("(.|/)x.com")):
            privateURL = str.replacingOccurrences(of: "x.com", with: twitterRedirect == "" ? "x.com" : twitterRedirect)
            conditionalIncreaseStats()
            //Youtube
        //TODO: Use the regex (\.|\/)youtube\.com instead of just finding any x.com link
        case let str where str.contains(try! Regex("(.|/)youtube.com")):
            privateURL = str.replacingOccurrences(of: "youtube.com", with: youtubeRedirect == "" ? "youtube.com" : youtubeRedirect).replacingOccurrences(of: "www.", with: "") //Instance located in the Netherlands
            conditionalIncreaseStats()
        //TODO: Use the regex (\.|\/)youtu\.be instead of just finding any x.com link
        case let str where str.contains(try! Regex("(.|/)youtu.be")):
            privateURL = str.replacingOccurrences(of: "youtu.be/", with: "\(youtubeRedirect == "" ? "youtube.com" : youtubeRedirect)/watch?v=")
            conditionalIncreaseStats()
            
            //Medium
        //TODO: Use the regex (\.|\/)medium\.com instead of just finding any x.com link
        case let str where str.contains(try! Regex("(.|/)medium.com")):
            privateURL = str.replacingOccurrences(of: "medium.com", with: mediumRedirect == "" ? "medium.com" : mediumRedirect) //Instance located in the Netherlands
            conditionalIncreaseStats()
            
            //Imgur
        case let str where str.contains(try! Regex("i.imgur.com/[a-zA-Z0-9]*.gifv")):
            privateURL = str
                .replacingOccurrences(of: "i.imgur.com", with: imgurRedirect == "" ? "i.imgur.com" : imgurRedirect) //rimgo.hostux.net is a french instance provided by Gandi.net
                .replacingOccurrences(of: ".gifv", with: imgurRedirect == "" ? ".gifv" : ".mp4")
            conditionalIncreaseStats()
            
            //If it cant match it just returns the url
        default:
            privateURL = url
        }
    }
    
    //remove tracking parameters
    if Defaults[.removeTrackingParams], let trackingParamRemover{
        dirtyURL = trackingParamRemover.cleanURL(URL(string: url)!).absoluteString
        privateURL = trackingParamRemover.cleanURL(URL(string: privateURL)!).absoluteString
    }
    
    return Post.PrivateURL(originalURL: dirtyURL, privateURL: privateURL)
}


//private func transformedMarkdown(_ string: String, trackingParamRemover: TrackingParamRemover?) -> String {
//    
//    @Default(.showOriginalURL) var showOriginalURL
//    
//    var transformedString = string
//    
//    // Case both sides are the url: [https://www.irunfar.com/2023-big-dogs-backyard-ultra-results](openartemis://www.irunfar.com/2023-big-dogs-backyard-ultra-results)
//    let case2Regex = try! NSRegularExpression(pattern: "\\[https?:\\/\\/[a-zA-Z0-9.\\/?=_-]*\\]\\(openartemis:\\/\\/[a-zA-Z0-9.\\/?=_-]*\\)")
//    // Case url but with text: [Hello World](openartemis://www.irunfar.com/2023-big-dogs-backyard-ultra-results)
//    let case3Regex = try! NSRegularExpression(pattern: "\\[[^https?:\\/\\/].*\\]\\(openartemis:\\/\\/[a-zA-Z0-9.\\/?=_-]*\\)")
//    
//    //Find matches
//    let case2Matches = case2Regex.matches(in: transformedString, options: [], range: NSMakeRange(0, transformedString.count))
//    let case3Matches = case3Regex.matches(in: transformedString, options: [], range: NSMakeRange(0, transformedString.count))
//
//    // - Loop throug the matches
//    // - Get the url from the comment
//    // - make the url private using transformedURL
//    // - reconstruct the text
//    // - replace old text with new text
//    for match in case2Matches {
//        let range = match.range(at: 0)
//        if let swiftRange = Range(range, in: transformedString) {
//            let matchingText = transformedString[swiftRange]
//            let url = String(String(matchingText).split(separator: "(")[1]).replacingOccurrences(of: ")", with: "")
//            let newURL = transformedURL(url, trackingParamRemover: trackingParamRemover)
//            let newText = "[\((showOriginalURL ? newURL.originalURL : newURL.privateURL).replacingOccurrences(of: "openartemis", with: "https"))](\(newURL.privateURL))"
//            transformedString.replaceSubrange(swiftRange, with: newText)
//            
//        }
//    }
//
//    for match in case3Matches {
//        let range = match.range(at: 0)
//        if let swiftRange = Range(range, in: transformedString) {
//            let matchingText = transformedString[swiftRange]
//            let url = String(String(matchingText).split(separator: "(")[1]).replacingOccurrences(of: ")", with: "")
//            let text = String(String(matchingText).split(separator: "]")[0]).replacingOccurrences(of: "[", with: "")
//            let newURL = transformedURL(url, trackingParamRemover: trackingParamRemover)
//            let newText = "[\(text)](\(newURL.privateURL))"
//            transformedString.replaceSubrange(swiftRange, with: newText)
//
//        }
//    }
//    
//    return transformedString
//}





extension String {
    func privacyURL(trackingParamRemover: TrackingParamRemover? = nil) -> Post.PrivateURL {
        transformedURL(self,trackingParamRemover: trackingParamRemover)
    }
    
//    func detectAndReplacePrivateURLSinMarkdown(trackingParamRemover: TrackingParamRemover? = nil) -> String {
//        transformedMarkdown(self, trackingParamRemover: trackingParamRemover)
//    }
}

///Typealias PrivateURL that represents a tuple where the first element is the original URL and the second Element is the new private one
typealias PrivateURL = (originalURL: String,privateURL: String)

func conditionalIncreaseStats(){
    @Default(.trackStats) var trackStats
    @Default(.URLsRedirected) var URLsRedirected
    
    if trackStats {
        URLsRedirected += 1
    }
}

