//
//  ScrapePost.swift
//  OpenArtemis
//
//  Created by daniel on 08/12/23.
//

import Foundation
import SwiftSoup

extension RedditScraper {
    static func scrapePostFromCommentsURL(url: String,trackingParamRemover: TrackingParamRemover?,completion: @escaping (Result<Post, Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        
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
                let post = try parsePostData(data: data, trackingParamRemover: trackingParamRemover)
                completion(.success(post))
            } catch {
                completion(.failure(error))
            }
        }.resume()
        
        
    }
    
    private static func parsePostData(data: Data, trackingParamRemover: TrackingParamRemover?)throws -> Post{
        let htmlString = String(data: data, encoding: .utf8)!
        let doc = try SwiftSoup.parse(htmlString)
        let postElement = try doc.select("div.link")

        
        let id = try postElement.attr("data-fullname")
        let subreddit = try postElement.attr("data-subreddit")
        let title = try postElement.select("p.title a.title").text()
        let author = try postElement.attr("data-author")
        let votes = try postElement.attr("data-score")
        let mediaURL = try postElement.attr("data-url")
        let commentsURL = try postElement.select("a.bylink.comments.may-blank").attr("href")
        
        let type = PostUtils.shared.determinePostType(mediaURL: mediaURL)
        
        var thumbnailURL: String? = nil
        
        if type == "video" || type == "gallery" || type == "article", let thumbnailElement = try? postElement.select("a.thumbnail img").first() {
            thumbnailURL = try? thumbnailElement.attr("src").replacingOccurrences(of: "//", with: "https://")
        }
        
        return Post(id: id, subreddit: subreddit, title: title, author: author, votes: votes, mediaURL: mediaURL.privacyURL(trackingParamRemover: trackingParamRemover), commentsURL: commentsURL, type: type, thumbnailURL: thumbnailURL)
    }
    
}
