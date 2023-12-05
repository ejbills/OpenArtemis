//
//  ScrapeComments.swift
//  OpenArtemis
//
//  Created by daniel on 05/12/23.
//

import Foundation
import SwiftSoup

extension RedditScraper {
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
            let score = try commentElement.select("span.score.unvoted").first()?.attr("title") ?? "[score hidden]"
            let time = try commentElement.select("time").first()?.attr("datetime") ?? ""
            let body = try commentElement.select("div.entry.unvoted > form[id^=form-\(id)]").text()
            
            let comment = Comment(id: id, parentID: parentID, childID: nil, author: author, score: score, time: time, body: body, depth: depth, isCollapsed: false, isRootCollapsed: false)
            comments.append(comment)
            
            commentIDs.insert(id)
            
            // Check for child comments
            if let childElement = try? commentElement.select("div.child > div.sitetable.listing > div.comment") {
                try childElement.enumerated().forEach { index, childCommentElement in
                    try parseComment(commentElement: childCommentElement, parentID: id, depth: depth + 1)
                    
                    // Add child ID to the previous comment (if any)
                    if index > 0 {
                        comments[comments.count - 2].childID = id
                    }
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
