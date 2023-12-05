//
//  scrapeSpecificSubreddit.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/28/23.
//

import Foundation
import SwiftSoup
import Erik

class RedditScraper {
    
    static func scrape(subreddit: String, lastPostAfter: String? = nil, trackingParamRemover: TrackingParamRemover?, completion: @escaping (Result<[Post], Error>) -> Void) {
        // Construct the URL for the Reddit website based on the subreddit
        guard let url = URL(string: lastPostAfter != nil ?
                            "\(baseRedditURL)/r/\(subreddit)/\(basePostCount)&after=\(lastPostAfter ?? "")" :
                                "\(baseRedditURL)/r/\(subreddit)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
                
        Erik.visit(url: url) { object, error in
            if let error = error {
                completion(.failure(error))
                return
            } else if let doc = object {
                do {
                    doc.querySelectorAll("div[class^=\"expando-button\"]").forEach { element in
                        element.click()
                    }
                    
                    // Get the HTML string from the document
                    let htmlString = doc.innerHTML

                    // Parse the HTML data into an array of Post objects
                    let posts = try parsePostData(data: htmlString ?? "", trackingParamRemover: trackingParamRemover)
                    completion(.success(posts))
                } catch {
                    completion(.failure(error))
                }
            } else {
                let unknownError = NSError(domain: "Unknown error", code: 0, userInfo: nil)
                completion(.failure(unknownError))
            }
        }
    }
    
    private static func parsePostData(data: String, trackingParamRemover: TrackingParamRemover?) throws -> [Post] {
        let doc = try SwiftSoup.parse(data)
        let postElements = try doc.select("div.link")
        
        let posts = postElements.compactMap { postElement -> Post? in
            do {
                let isAd = try postElement.classNames().contains("promoted")
                
                guard !isAd else {
                    return nil
                }
                
                let id = try postElement.attr("data-fullname")
                let subreddit = try postElement.attr("data-subreddit")
                let title = try postElement.select("p.title a.title").text()
                let author = try postElement.attr("data-author")
                let score = try postElement.attr("data-score")
                var mediaURL = try postElement.attr("data-url")
                
                let type = determinePostType(mediaURL: mediaURL)
                
                if type == "video" {
                    if let videoDiv = try postElement.select("div.expando.expando-uninitialized").first() {
                        let cachedHtml = try videoDiv.attr("data-cachedhtml")
                                   
                       // Parse the nested HTML string
                       let nestedDoc = try SwiftSoup.parse(cachedHtml)
                       
                       // Find the div with the data-hls-url attribute
                        if let videoDiv = try nestedDoc.select("div[data-hls-url]").first() {
                            
                            // Get the data-hls-url attribute value
                            let videoUrl = try videoDiv.attr("data-hls-url")
                            mediaURL = videoUrl
                        }
                    }
                }
                
                var thumbnailURL: String? = nil
                
                if type == "video" || type == "gallery" || type == "article", let thumbnailElement = try? postElement.select("a.thumbnail img").first() {
                    thumbnailURL = try? thumbnailElement.attr("src").replacingOccurrences(of: "//", with: "https://")
                }
                
                return Post(id: id, subreddit: subreddit, title: title, author: author, score: score, mediaURL: mediaURL.privacyURL(trackingParamRemover: trackingParamRemover), type: type, thumbnailURL: thumbnailURL)
            } catch {
                // Handle any specific errors here if needed
                print("Error parsing post element: \(error)")
                return nil
            }
        }
        
        return posts
    }
    
}

