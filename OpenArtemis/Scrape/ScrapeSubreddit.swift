//
//  ScrapeSubreddit.swift
//  OpenArtemis
//
//  Created by daniel on 05/12/23.
//

import Foundation
import SwiftSoup

class RedditScraper {
    static let webViewManager = HeadlessWebManager()
    
    static func scrapeSubreddit(subreddit: String, lastPostAfter: String? = nil, sort: SortOption? = nil,
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
                urlComponents?.path += "/\(sort.rawVal.value)/"
            case .top(let topOption):
                urlComponents?.path += "/top/"
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

        webViewManager.loadURLAndGetHTML(url: redditURL, autoClickExpando: true, preventCacheClear: lastPostAfter != nil) { result in
            switch result {
            case .success(let htmlContent):
                do {
                    // Use SwiftSoup to parse the HTML content into Post objects.
                    let posts = try parsePostData(html: htmlContent, trackingParamRemover: trackingParamRemover)
                    completion(.success(posts))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func scrapeSubredditIcon(subreddit: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let aboutURL = URL(string: "\(newBaseRedditURL)/r/\(subreddit)/about") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        GlobalLoadingManager.shared.setLoading(toState: true)
        
        var request = URLRequest(url: aboutURL)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer {
                GlobalLoadingManager.shared.setLoading(toState: false)
            }
            
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
                if let iconElement = try doc.select("faceplate-img[src*=redditmedia]").first() {
                    let src = try iconElement.attr("src")
                    completion(.success(src))
                } else {
                    GlobalLoadingManager.shared.toastFailure()
                    completion(.failure(NSError(domain: "Icon not found", code: 0, userInfo: nil)))
                }
            } catch {
                GlobalLoadingManager.shared.toastFailure()
                completion(.failure(error))
            }
        }.resume()
    }
    
    static func parsePostData(html: String, trackingParamRemover: TrackingParamRemover?) throws -> [Post] {
        let doc = try SwiftSoup.parse(html)
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
                
                let commentsElement = try postElement.select("a.bylink.comments.may-blank")
                let commentsURL = try commentsElement.attr("href")
                let commentsCount = try commentsElement.text().split(separator: " ").first.map(String.init) ?? ""
                
                let type = PostUtils.shared.determinePostType(mediaURL: mediaURL)
                
                var thumbnailURL: String? = nil
                
                if type == "video" || type == "gallery" || type == "article", let thumbnailElement = try? postElement.select("a.thumbnail img").first() {
                    thumbnailURL = try? thumbnailElement.attr("src").replacingOccurrences(of: "//", with: "https://")
                }
                
                return Post(id: id, subreddit: subreddit, title: title, tag: tag, author: author, votes: votes, time: time, mediaURL: mediaURL.privacyURL(trackingParamRemover: trackingParamRemover), commentsURL: commentsURL, commentsCount: commentsCount, type: type, thumbnailURL: thumbnailURL)
            } catch {
                // Handle any specific errors here if needed
                print("Error parsing post element: \(error)")
                return nil
            }
        }

        return posts
    }
}
