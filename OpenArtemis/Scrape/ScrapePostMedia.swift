//
//  ScrapeComments.swift
//  OpenArtemis
//
//  Created by daniel on 05/12/23.
//

import Foundation
import SwiftSoup
import SwiftHTMLtoMarkdown
import Defaults

private let invalidURLError = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
private let noDataError = NSError(domain: "No data received", code: 0, userInfo: nil)

extension RedditScraper {
    private static func parseUserTextBody(data: Document, trackingParamRemover: TrackingParamRemover) throws -> String? {
        let postBody = try data.select("div.expando").first()
        
        var body: String? = nil
        if let bodyElement = postBody, !(try bodyElement.text().isEmpty) {
            let modifiedHtmlBody = try redditLinksToInternalLinks(bodyElement)
            
            var document = MastodonHTML(rawHTML: modifiedHtmlBody)
            try document.parse()
            body = try document.asMarkdown()
        }
        
        return body
    }

    static func scrapeComments(commentURL: String,trackingParamRemover: TrackingParamRemover, completion: @escaping (Result<(comments: [Comment], postBody: String?), Error>) -> Void) {
        let url = URL(string: commentURL)!
        var request = URLRequest(url: url)
        request.setValue("text/html", forHTTPHeaderField: "Accept")

        let group = DispatchGroup()
        var commentsResult: Result<[Comment], Error>?
        var postBodyResult: Result<String?, Error>?

        group.enter()
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }

            do {
                
                let htmlString = String(data: data, encoding: .utf8)!
                let doc = try SwiftSoup.parse(htmlString)

                let comments = try parseCommentsData(data: doc, trackingParamRemover: trackingParamRemover)
                let postBody = try parseUserTextBody(data: doc, trackingParamRemover: trackingParamRemover)

                completion(.success((comments: comments, postBody: postBody)))
            } catch {
                completion(.failure(error))
            }
        }.resume()

        group.notify(queue: .main) {
            let result: Result<(comments: [Comment], postBody: String?), Error>

            switch (commentsResult, postBodyResult) {
            case let (.success(comments), .success(postBody)):
                result = .success((comments: comments, postBody: postBody))
            case let (.failure(error), _):
                result = .failure(error)
            case let (_, .failure(error)):
                result = .failure(error)
            default:
                fatalError("Invalid state")
            }

            completion(result)
        }

    }
    
    static func parseCommentsData(data: Document, trackingParamRemover: TrackingParamRemover) throws -> [Comment] {
        var comments: [Comment] = []
        var commentIDs = Set<String>()
        
        // Elements for reduced calls
        let topLevelComments = try? data.select("div.sitetable.nestedlisting > div.comment")

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
            
            let bodyElement = try commentElement.select("div.entry.unvoted > form[id^=form-\(id)]").first()

            // Replace links in HTML with internal links, and convert body to markdown
            var body = ""
            if let bodyElement = bodyElement {
                let modifiedHtmlBody = try redditLinksToInternalLinks(bodyElement)
                
                var document = MastodonHTML(rawHTML: modifiedHtmlBody)
                try document.parse()
                body = try document.asMarkdown()
            }
            
            // check for stickied tag
            let stickiedElement = try commentElement.select("span.stickied-tagline").first()
            let stickied = stickiedElement != nil
            
            let directURL = try commentElement.select("a.bylink").attr("href")

            let comment = Comment(id: id, parentID: parentID, author: author, score: score, time: time, body: body,
                                  depth: depth, stickied: stickied, directURL: directURL, isCollapsed: false, isRootCollapsed: stickied)
            comments.append(comment)
            
            // Check for child comments
            if let childElement = try? commentElement.select("div.child > div.sitetable.listing > div.comment") {
                try childElement.forEach { childCommentElement in
                    try parseComment(commentElement: childCommentElement, parentID: id, depth: depth + 1)
                }
            }
        }
        
        // Parse top-level comments
        if let topLevelComments = topLevelComments {
            comments.reserveCapacity(topLevelComments.size())
            try topLevelComments.forEach { commentElement in
                try parseComment(commentElement: commentElement, parentID: nil, depth: 0)
            }
        }
        
        return comments
    }
    
    static func scrapePostFromCommentsURL(url: String,trackingParamRemover: TrackingParamRemover?, completion: @escaping (Result<Post, Error>) -> Void) {
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
                let post = try parsePostData(data: data, trackingParamRemover: trackingParamRemover).first
                if let post = post {
                    completion(.success(post))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

func redditLinksToInternalLinks(_ element: Element) throws -> String {
    do {
        let links = try element.select("a[href]")

        for link in links.array() {
            let originalHref = try link.attr("href")
    
            if originalHref.hasPrefix("/r/") || originalHref.hasPrefix("/u/") {
                try link.attr("href", "openartemis://\(originalHref)")
            } else {
                let trimmedHref = originalHref.privacyURL().privateURL.replacingOccurrences(of: "^(https?://)", with: "", options: .regularExpression)
                if !Defaults[.showOriginalURL] {
                    try link.text(originalHref.replacingOccurrences(of: "https:\\/\\/[a-zA-Z-0-9.\\/?=_\\-\\:]*", with: originalHref.privacyURL().privateURL, options: .regularExpression))
                }
                try link.attr("href", "openartemis://\(trimmedHref)")
            }
        }
        return try element.html()
    } catch {
        throw error
    }
}
