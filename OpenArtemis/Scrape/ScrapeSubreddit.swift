//
//  scrapeSpecificSubreddit.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/28/23.
//

import Foundation
import Combine
import SwiftSoup

class RedditScraper {
    static func scrapeSubreddit(subreddit: String, lastPostAfter: String? = nil,trackingParamRemover: TrackingParamRemover?, completion: @escaping (Result<[Post], Error>) -> Void) {
        // Construct the URL for the Reddit website based on the subreddit
        guard let url = URL(string: lastPostAfter != nil ?
                            "\(baseRedditURL)/r/\(subreddit)/\(basePostCount)&after=\(lastPostAfter ?? "")" :
                                "\(baseRedditURL)/r/\(subreddit)") else {
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
                let votes = try postElement.attr("data-score")
                let mediaURL = try postElement.attr("data-url")
                let commentsURL = try postElement.select("a.bylink.comments.may-blank").attr("href")
                
                let type = determinePostType(mediaURL: mediaURL)
                
                var thumbnailURL: String? = nil
                
                if type == "video" || type == "gallery" || type == "article", let thumbnailElement = try? postElement.select("a.thumbnail img").first() {
                    thumbnailURL = try? thumbnailElement.attr("src").replacingOccurrences(of: "//", with: "https://")
                }
                
                return Post(id: id, subreddit: subreddit, title: title, author: author, votes: votes, mediaURL: mediaURL.privacyURL(trackingParamRemover: trackingParamRemover), commentsURL: commentsURL, type: type, thumbnailURL: thumbnailURL)
            } catch {
                // Handle any specific errors here if needed
                print("Error parsing post element: \(error)")
                return nil
            }
        }
        
        return posts
    }
    
    static func scrapeComments(commentURL: String, completion: @escaping (Result<[Comment], Error>) -> Void) {
        guard let url = URL(string: commentURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
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
                let comments = try parseCommentsData(data: data)
                completion(.success(comments))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private static func parseCommentsData(data: Data) throws -> [Comment] {
        let htmlString = String(data: data, encoding: .utf8)!
        let doc = try SwiftSoup.parse(htmlString)

        var comments: [Comment] = []
        var commentIDs = Set<String>()

        // Function to recursively parse comments
        func parseComment(commentElement: Element, parentID: String?, depth: Int) throws {
            let id = try commentElement.attr("data-fullname")

            // Check for duplicate comments
            guard !commentIDs.contains(id) else {
                return
            }

            let author = try commentElement.attr("data-author")
            let score = try commentElement.select("span.score.unvoted").first()?.text() ?? "[score hidden]"
            let time = try commentElement.select("time").first()?.attr("datetime") ?? ""
            // commenting this temporarily till html rendering is fixed.
            // let body = try commentElement.select("div.entry.unvoted > form[id^=form-\(id)]").html()
            let body = try commentElement.select("div.entry.unvoted > form[id^=form-\(id)]").text()

            let comment = Comment(id: id, parentID: parentID, author: author, score: score, time: time, body: body, depth: depth, isCollapsed: false, isRoot: false)
            comments.append(comment)
            commentIDs.insert(id)

            // Check for child comments
            if let childElement = try? commentElement.select("div.child > div.sitetable.listing > div.comment") {
                try childElement.forEach { childCommentElement in
                    try parseComment(commentElement: childCommentElement, parentID: id, depth: depth + 1)
                }
            }
        }

        // Parse top-level comments
        try doc.select("div.sitetable.nestedlisting > div.comment").forEach { commentElement in
            try parseComment(commentElement: commentElement, parentID: nil, depth: 0)
        }

        return comments
    }
}
