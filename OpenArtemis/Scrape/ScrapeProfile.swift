//
//  ScrapeProfile.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/26/23.
//

import SwiftUI
import SwiftSoup

extension RedditScraper {
    static func scrapeProfile(username: String, lastPostAfter: String?, filterType: String?,
                              trackingParamRemover: TrackingParamRemover?, over18: Bool? = false,
                              completion: @escaping (Result<[MixedMedia], Error>) -> Void) {
        // Construct the base URL for the Reddit user's profile
        var urlString = "\(baseRedditURL)/user/\(username)"

        // Append filter type to the URL if provided
        if let filterType = filterType, !filterType.isEmpty {
            urlString += "/\(filterType)"
        }

        // Append after parameter to the URL if lastPostAfter is provided
        if let lastPostAfter = lastPostAfter, !lastPostAfter.isEmpty {
            urlString += "?after=\(lastPostAfter)"
        }

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        webViewManager.loadURLAndGetHTML(url: url, autoClickExpando: true) { result in
            switch result {
            case .success(let htmlContent):
                do {

                    let posts = try parsePostData(html: htmlContent, trackingParamRemover: trackingParamRemover)
                        let comments = try parseProfileComments(html: htmlContent, trackingParamRemover: trackingParamRemover)

                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

                        // Combine posts and comments into an array of MixedMedia
                        var mixedMediaLinks: [MixedMedia] = []

                        // Iterate over posts and add to mixedMediaLinks
                        for post in posts {
                            mixedMediaLinks.append(MixedMedia.post(post, date: dateFormatter.date(from: post.time)))
                        }

                        // Iterate over comments and add to mixedMediaLinks
                        for comment in comments {
                            mixedMediaLinks.append(MixedMedia.comment(comment, date: dateFormatter.date(from: comment.time)))
                        }

                        DateSortingUtils.sortMixedMediaByDateDescending(&mixedMediaLinks)

                        completion(.success(mixedMediaLinks))
                    } catch {
                        // Catches error from `parsePostData` or `parseProfileComments`.
                        completion(.failure(error))
                    }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    static func parseProfileComments(html: String, trackingParamRemover: TrackingParamRemover?) throws -> [Comment] {
        let doc = try SwiftSoup.parse(html)
        let commentElements = try doc.select("div.thing.comment")
        
        let comments = commentElements.compactMap { commentElement -> Comment? in
            do {
                return try parseProfileCommentElement(commentElement: commentElement, trackingParamRemover: trackingParamRemover)
            } catch {
                // Handle any specific errors here if needed
                print("Error parsing comment element: \(error)")
                return nil
            }
        }

        return comments
    }

    private static func parseProfileCommentElement(commentElement: Element, trackingParamRemover: TrackingParamRemover?) throws -> Comment {
        let id = try commentElement.attr("data-fullname")
        let parentID = try? commentElement.attr("data-parent-fullname")
        let author = try commentElement.attr("data-author")
        let scoreText = try commentElement.select("span.score.unvoted").first()?.text() ?? ""
        let score = scoreText.components(separatedBy: " ").first ?? "[score hidden]"
        let time = try commentElement.select("time").first()?.attr("datetime") ?? ""

        let bodyElement = try commentElement.select("div.entry.unvoted > form[id*=form-\(id)]").first()

        // Replace links in HTML with internal links, and convert body to markdown
        var body = ""
        if let bodyElement = bodyElement {
            let modifiedHtmlBody = try redditLinksToInternalLinks(bodyElement)

            var document = ArtemisHTML(rawHTML: modifiedHtmlBody)
            try document.parse()
            body = try document.asMarkdown()
        }

        // Check for stickied tag
        let stickiedElement = try commentElement.select("span.stickied-tagline").first()
        let stickied = stickiedElement != nil

        let directURL = try commentElement.select("a.bylink").attr("href")
        
        return Comment(id: id, parentID: parentID, author: author, score: score, time: time, body: body,
                       depth: 0, stickied: stickied, directURL: directURL, isCollapsed: false, isRootCollapsed: stickied)
    }
}
