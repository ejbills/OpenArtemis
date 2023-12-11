//
//  ScrapeSubreddit.swift
//  OpenArtemis
//
//  Created by daniel on 05/12/23.
//

import Foundation
import SwiftSoup

class RedditScraper {
    static func scrapeSubreddit(subreddit: String, lastPostAfter: String? = nil, sort: SubListingSortOption? = nil,
                                trackingParamRemover: TrackingParamRemover?,
                                over18: Bool? = false,
                                completion: @escaping (Result<[Post], Error>) -> Void) {
        
        // Construct the URL for the Reddit website based on the subreddit
        var urlComponents = URLComponents(string: "\(baseRedditURL)/r/\(subreddit)")
        var queryItems = [URLQueryItem]()

        // Add sort path component
        if let sort = sort {
            switch sort {
            case .best, .hot, .new, .controversial:
                urlComponents?.path += "/\(sort.rawVal.value)"
            case .top(let topOption):
                urlComponents?.path += "/top"
                queryItems.append(URLQueryItem(name: "t", value: topOption.rawValue))
            }
        }

        // Add remaining parameters to the URL
        queryItems.append(URLQueryItem(name: "count", value: basePostCount))
        if let lastPostAfter = lastPostAfter {
            queryItems.append(URLQueryItem(name: "after", value: lastPostAfter))
        }

        urlComponents?.queryItems = queryItems

        guard let redditURL = urlComponents?.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        // Create a URLSession and make a data task to fetch the HTML content
        URLSession.shared.dataTask(with: redditURL) { data, response, error in
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
                            scrapeSubreddit(subreddit: subreddit, lastPostAfter: lastPostAfter, sort: sort, trackingParamRemover: trackingParamRemover, completion: completion)
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    })
                } else {
                    // If not redirected, parse the HTML data into an array of Post objects
                    let posts = try parsePostData(data: data, trackingParamRemover: trackingParamRemover)
                    completion(.success(posts))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    static func sendOver18Request(url: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "over18=yes".data(using: .utf8)

        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
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
                let tag = try postElement.select("span.linkflairlabel").first()?.text() ?? ""
                let author = try postElement.attr("data-author")
                let votes = try postElement.attr("data-score")
                let time = try postElement.select("time").attr("datetime")
                let mediaURL = try postElement.attr("data-url")
                let commentsURL = try postElement.select("a.bylink.comments.may-blank").attr("href")
                
                let type = PostUtils.shared.determinePostType(mediaURL: mediaURL)
                
                var thumbnailURL: String? = nil
                
                if type == "video" || type == "gallery" || type == "article", let thumbnailElement = try? postElement.select("a.thumbnail img").first() {
                    thumbnailURL = try? thumbnailElement.attr("src").replacingOccurrences(of: "//", with: "https://")
                }
                
                return Post(id: id, subreddit: subreddit, title: title, tag: tag, author: author, votes: votes, time: time, mediaURL: mediaURL.privacyURL(trackingParamRemover: trackingParamRemover), commentsURL: commentsURL, type: type, thumbnailURL: thumbnailURL)
            } catch {
                // Handle any specific errors here if needed
                print("Error parsing post element: \(error)")
                return nil
            }
        }
        
        return posts
    }
}
