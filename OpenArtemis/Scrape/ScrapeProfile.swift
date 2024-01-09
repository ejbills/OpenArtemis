//
//  ScrapeProfile.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/26/23.
//

import SwiftUI
import SwiftSoup
import SwiftHTMLtoMarkdown

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
                // Check if the URL has been redirected to an over18 page
                if let redirectURL = response?.url, redirectURL.absoluteString.hasPrefix("https://old.reddit.com/over18?dest="), over18 ?? false {
                    // If redirected, send a POST request to the over18 endpoint
                    sendOver18Request(url: redirectURL, completion: { result in
                        switch result {
                        case .success:
                            // If the POST request is successful, reload the original URL
                            scrapeProfile(username: username, lastPostAfter: lastPostAfter, filterType: filterType, trackingParamRemover: trackingParamRemover, over18: over18, completion: completion)
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    })
                } else {
                    // If not redirected, parse the HTML data into an array of Post and Comment objects
                    let posts = try parsePostData(data: data, trackingParamRemover: trackingParamRemover)
                    let comments = try parseProfileComments(data: data, trackingParamRemover: trackingParamRemover)

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
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    static func parseProfileComments(data: Data, trackingParamRemover: TrackingParamRemover?) throws -> [Comment] {
        let htmlString = String(data: data, encoding: .utf8)!
        let doc = try SwiftSoup.parse(htmlString)
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

            var document = BasicHTML(rawHTML: modifiedHtmlBody)
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
