//
//  ScrapeSearch.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/21/23.
//

import Foundation
import SwiftSoup
import Defaults

extension RedditScraper {
    static func search(query: String, searchType: String, sortBy: PostSortOption, topSortBy: TopPostListingSortOption,
                       trackingParamRemover: TrackingParamRemover?, over18: Bool? = false,
                       completion: @escaping (Result<[MixedMedia], Error>) -> Void) {
        // Construct the URL for the Reddit search based on the query
        var urlComponents = URLComponents(string: "\(baseRedditURL)/search")
        var queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: searchType)
        ]

        if searchType.isEmpty {
            // Only include these parameters if searchType is empty (post search)
            queryItems.append(URLQueryItem(name: "sort", value: sortBy.rawValue))
            queryItems.append(URLQueryItem(name: "t", value: topSortBy.rawValue))
        }
        
        // Add include_over_18=on if over18 is true
        if over18 == true {
            queryItems.append(URLQueryItem(name: "include_over_18", value: "on"))
        }
        
        urlComponents?.queryItems = queryItems

        guard let searchURL = urlComponents?.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        // Create a URLSession and make a data task to fetch the HTML content
        var request = URLRequest(url: searchURL)
        request.setValue("text/html", forHTTPHeaderField: "Accept")
        
        URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)

        request.cachePolicy = .reloadIgnoringLocalCacheData

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
                
                var mixedMediaResults: [MixedMedia] = []

                if searchType == "sr" { // subreddit search
                    let subreddits = scrapeSubredditResults(data: doc)
                    mixedMediaResults.append(contentsOf: subreddits.map { MixedMedia.subreddit($0) })
                } else if searchType.isEmpty { // no filter is a post search
                    let posts = scrapePostResults(data: doc, trackingParamRemover: trackingParamRemover)
                    mixedMediaResults.append(contentsOf: posts.map { MixedMedia.post($0, date: nil) })
                }

                completion(.success(mixedMediaResults))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private static func scrapeSubredditResults(data: Document) -> [Subreddit] {
        do {
            // Select all elements with class "search-result-subreddit"
            let subredditElements = try data.select("div.search-result-subreddit")
            
            // Create an array to store the results
            var subreddits: [Subreddit] = []
            
            // Iterate over each subreddit element
            for subredditElement in subredditElements {
                // Extract the subreddit name from the "search-title" class
                let subredditName = try subredditElement.select("a.search-subreddit-link.may-blank").text().split(separator: "/").last.map { String($0) } ?? ""
                // Create a Subreddit object and add it to the array
                let subreddit = Subreddit(subreddit: subredditName)
                subreddits.append(subreddit)
            }
            
            return subreddits
        } catch {
            return []
        }
    }
    
    private static func scrapePostResults(data: Document, trackingParamRemover: TrackingParamRemover?) -> [Post] {
        let postElements = try? data.select("div.search-result-link")
        
        let keywordFilters = Defaults[.keywordFilters]
        let userFilters = Defaults[.userFilters]
        let subredditFilters = Defaults[.subredditFilters]

        return postElements?.compactMap { postElement -> Post? in
            do {
                // Get subreddit first for early filtering
                let subreddit = try postElement.select("a.search-subreddit-link.may-blank").text()
                let cleanedSubredditLink = subreddit.replacingOccurrences(of: "^(r/|/r/)", with: "", options: .regularExpression)
                
                // Filter out banned subreddits
                guard !subredditFilters.contains(cleanedSubredditLink.lowercased()) else {
                    return nil
                }
                
                // Get author early for filtering
                let author = try postElement.select("span.search-author a").text()
                
                // Filter out banned users
                guard !userFilters.contains(author.lowercased()) else {
                    return nil
                }
                
                // Get title for keyword filtering
                let title = try postElement.select("a.search-title.may-blank").text()
                
                // Filter out posts with banned keywords in title
                let lowercasedTitle = title.lowercased()
                guard !keywordFilters.contains(where: { keyword in
                    lowercasedTitle.contains(keyword.lowercased())
                }) else {
                    return nil
                }
                
                let id = try postElement.attr("data-fullname")
                let tagElement = try postElement.select("span.linkflairlabel").first()
                let tag = try tagElement?.text() ?? ""
                let votes = try postElement.select("span.search-score").text()
                let time = try postElement.select("span.search-time time").attr("datetime")
                
                let commentsURL = try postElement.select("a.search-comments.may-blank").attr("href")
                let commentsCount = try postElement.select("a.search-comments.may-blank").text().split(separator: " ").first.map(String.init) ?? ""
                
                let footerElement = try postElement.select("div.search-result-footer").first()
                let mediaURL = try footerElement?.select("a.search-link.may-blank").attr("href") ?? commentsURL
                
                let type = PostUtils.shared.determinePostType(mediaURL: mediaURL)

                var thumbnailURL: String? = nil

                if type == "video" || type == "gallery" || type == "article", let thumbnailElement = try? postElement.select("a.thumbnail img").first() {
                    thumbnailURL = try? thumbnailElement.attr("src").replacingOccurrences(of: "//", with: "https://")
                }

                return Post(id: id, subreddit: cleanedSubredditLink, title: title, tag: tag, author: author, votes: votes, time: time, mediaURL: mediaURL.privacyURL(trackingParamRemover: trackingParamRemover), commentsURL: commentsURL, commentsCount: commentsCount, type: type, thumbnailURL: thumbnailURL)
            } catch {
                print("Error parsing post element: \(error)")
                return nil
            }
        } ?? []
    }
}
