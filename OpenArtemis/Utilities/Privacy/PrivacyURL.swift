//
//  PrivacyURL.swift
//  OpenArtemis
//
//  Created by daniel on 02/12/23.
//

import Foundation
import Defaults

private func transformedURL(_ url: String, trackingParamRemover: TrackingParamRemover? = nil) -> PrivateURL {
  @Default(.redirectToPrivateSites) var redirectToPrivateSites
  var privateURL: String = url
  var dirtyURL: String = url
  // This matches all the urls that we want to replace and changes them to the private one
  if redirectToPrivateSites {
    switch url {
      
    //TwitterA
    case let str where str.contains("twitter.com"):
      privateURL = str.replacingOccurrences(of: "twitter.com", with: "nitter.net") //Instance located in the Netherlands
    case let str where str.contains("x.com"):
      privateURL = str.replacingOccurrences(of: "x.com", with: "nitter.net")
      
    //Youtube
    case let str where str.contains("youtube.com"):
      privateURL = str.replacingOccurrences(of: "youtube.com", with: "yewtu.be").replacingOccurrences(of: "www.", with: "") //Instance located in the Netherlands
    case let str where str.contains("youtu.be"):
      privateURL = str.replacingOccurrences(of: "youtu.be/", with: "yewtu.be/watch?v=")
      
    //Medium
    case let str where str.contains("medium.com"):
      privateURL = str.replacingOccurrences(of: "medium.com", with: "scribe.rip") //Instance located in the Netherlands
       
      
    //Imgur
    case let str where str.contains(try! Regex("i.imgur.com/[a-zA-Z0-9]*.gifv")):
      privateURL = str
        .replacingOccurrences(of: "i.imgur.com", with: "rimgo.hostux.net") //rimgo.hostux.net is a french instance provided by Gandi.net
        .replacingOccurrences(of: ".gifv", with: ".mp4")
      
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
  
  return (dirtyURL, privateURL)
}

extension String {
  func privacyURL(trackingParamRemover: TrackingParamRemover? = nil) -> PrivateURL {
    transformedURL(self,trackingParamRemover: trackingParamRemover)
  }
}

///Typealias PrivateURL that represents a tuple where the first element is the original URL and the second Element is the new private one
typealias PrivateURL = (originalURL: String,privateURL: String)

