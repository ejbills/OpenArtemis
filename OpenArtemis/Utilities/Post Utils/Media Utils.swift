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
                
                // Target the gallery-preview divs that contain the full resolution images
                let galleryPreviews = try document.select("div.gallery-preview div.media-preview-content a.gallery-item-thumbnail-link")
                
                // Extract hrefs which contain the full resolution image URLs
                let imageUrls = galleryPreviews.map { element in
                    if let imageUrlString = try? element.attr("href") {
                        return imageUrlString
                    }
                    return nil
                }.compactMap { $0 }
                
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
