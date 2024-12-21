//
//  Media Utils.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/30/23.
//

import Foundation
import SwiftSoup
import OpenGraph

class MediaUtils {
    static func galleryMediaExtractor(galleryURL: URL, completion: @escaping ([String]?) -> Void) {
        let task = URLSession.shared.dataTask(with: galleryURL) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let htmlString = String(data: data, encoding: .utf8)
                let document = try SwiftSoup.parse(htmlString ?? "")
                
                // gallery url does not contain img links
                // https://www.reddit.com/gallery/abcdefg
                // need to redirect to comment url, but does not redirect automatically without loading js
                // https://www.reddit.com/r/subreddit/comments/abcdefg/the_post_name/
                
                if let redirect = try? document.select("shreddit-redirect").attr("href"),
                   redirect.hasPrefix("/r/"),
                   var urlComponents = URLComponents(url: galleryURL, resolvingAgainstBaseURL: false) {
                    
                    // set the relative redirect path
                    // /r/subreddit/comments/abcdefg/the_post_name/
                    urlComponents.path = redirect
                    
                    // run again to extract media from the redirected url
                    if let url = urlComponents.url, url != galleryURL {
                        return Self.galleryMediaExtractor(galleryURL: url, completion: completion)
                    }
                    
                }
                
                // extract images from carousel on comment page
                // /r/subreddit/comments/abcdefg/the_post_name/
                // there are 2 <img> tags, one directly in <li>, one in nested <figure>.
                // Only extract one to prevent duplicate images
                let imageUrls = try document.select("gallery-carousel ul li>img")
                    .compactMap {
                        // first image is loaded and has a src
                        if let src = try? $0.attr("src"), !src.isEmpty {
                            return src
                        }
                        // other images are not loaded yet, different attribute
                        return try? $0.attr("data-lazy-src")
                    }
                
                completion(imageUrls)
            } catch {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    static func videoMediaExtractor(videoURL: URL, completion: @escaping (URL?) -> Void) {
        let task = URLSession.shared.dataTask(with: videoURL) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            //Return the url if its already a media url
            if videoURL.isVideoMediaURL() {
                completion(videoURL)
            } else {
                do {
                    let htmlString = String(data: data, encoding: .utf8)
                    let doc = try SwiftSoup.parse(htmlString!)
                    
                    // Extract video link
                    if let videoElement = try doc.select("shreddit-player-2 source").first() ?? doc.select("shreddit-player source").first(),
                       let videoUrlString = try? videoElement.attr("src"),
                       let videoUrl = URL(string: videoUrlString) {
                        completion(videoUrl)
                    } else {
                        completion(nil)
                    }
                } catch {
                    completion(nil)
                }
            }
            
        }
        
        task.resume()
    }
    
    static func fetchImageURL(urlString: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        Task(priority: .background) {
            var headers = [String: String]()
            headers["User-Agent"] = "facebookexternalhit/1.1"
            headers["charset"] = "UTF-8"
            
            OpenGraph.fetch(url: url, headers: headers) { result in
                switch result {
                case .success(let og):
                    if let imageURL = og[.image] {
                        completion(imageURL)
                    } else {
                        completion(nil)
                    }
                case .failure(let error):
                    print(error)
                    completion(nil)
                }
            }
        }
    }
}
