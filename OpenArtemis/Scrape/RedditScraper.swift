//
//  scrapeSpecificSubreddit.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/28/23.
//

import Foundation
import SwiftSoup

class RedditScraper {
    
  static func scrape(subreddit: String, lastPostAfter: String? = nil,trackingParamRemover: TrackingParamRemover?, completion: @escaping (Result<[Post], Error>) -> Void) {
        // Construct the URL for the Reddit website based on the subreddit
        guard let url = URL(string: lastPostAfter != nil ?
                            "\(baseRedditURL)/r/\(subreddit)/\(basePostCount)&after=\(lastPostAfter ?? "")" :
                            "\(baseRedditURL)/r/\(subreddit)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        print(url.absoluteString)
        
        // Create a URLSession and make a data task to fetch the HTML content
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            
            do {
                // Parse the HTML data into an array of Post objects
                // trackingParamRemover goes on a bit of an adventure and needs to be passed all the way down to privacyURL(trackingParamRemover: trackingParamRemover). It can be set to nil.
                let posts = try parsePostData(data: data, trackingParamRemover: trackingParamRemover)
                completion(.success(posts))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
  private static func parsePostData(data: Data, trackingParamRemover: TrackingParamRemover?) throws -> [Post] {
        let htmlString = String(data: data, encoding: .utf8)!
        let doc = try SwiftSoup.parse(htmlString)
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
                let mediaURL = try postElement.attr("data-url")
                
                let type = determinePostType(mediaURL: mediaURL)
                
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

