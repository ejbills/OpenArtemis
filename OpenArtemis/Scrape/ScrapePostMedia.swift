//
//  ScrapeComments.swift
//  OpenArtemis
//
//  Created by daniel on 05/12/23.
//

import Foundation
import SwiftSoup

extension RedditScraper {
    private static func parseUserTextBody(data: Data) throws -> String? {
        let htmlString = String(data: data, encoding: .utf8)!
        let doc = try SwiftSoup.parse(htmlString)
        
        guard let userTextBody = try doc.select("div.expando").first()?.text() else {
            throw NSError(domain: "Could not find user text body", code: 0, userInfo: nil)
        }
        
        return userTextBody
    }
    
    static func scrapeComments(commentURL: String, completion: @escaping (Result<(comments: [Comment], postBody: String?), Error>) -> Void) {
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
                
                // Call parseUserTextBody
                if let postBody = try? parseUserTextBody(data: data) {
                    completion(.success((comments: comments, postBody: postBody)))
                } else {
                    completion(.success((comments: comments, postBody: nil)))
                }
                
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
            guard commentIDs.insert(id).inserted else {
                return
            }
            
            let author = try commentElement.attr("data-author")
            
            let scoreText = try commentElement.select("span.score.unvoted").first()?.text() ?? ""
            let score = scoreText.components(separatedBy: " ").first ?? "[score hidden]"
            
            let time = try commentElement.select("time").first()?.attr("datetime") ?? ""
            let body = try commentElement.select("div.entry.unvoted > form[id^=form-\(id)]").text()
            
            // check for stickied tag
            let stickiedElement = try commentElement.select("span.stickied-tagline").first()
            let stickied = stickiedElement != nil
            
            let comment = Comment(id: id, parentID: parentID, author: author, score: score, time: time, body: body,
                                  depth: depth, stickied: stickied, isCollapsed: false, isRootCollapsed: stickied)
            comments.append(comment)
            
            // Check for child comments
            if let childElement = try? commentElement.select("div.child > div.sitetable.listing > div.comment") {
                try childElement.forEach { childCommentElement in
                    try parseComment(commentElement: childCommentElement, parentID: id, depth: depth + 1)
                }
            }
        }
        
        // Parse top-level comments
        if let topLevelComments = try? doc.select("div.sitetable.nestedlisting > div.comment") {
            comments.reserveCapacity(topLevelComments.size())
            try topLevelComments.forEach { commentElement in
                try parseComment(commentElement: commentElement, parentID: nil, depth: 0)
            }
        }
        
        return comments
    }
}
