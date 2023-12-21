//
//  ScrapeSearch.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/21/23.
//

import Foundation
import SwiftSoup

extension RedditScraper {
    static func search(query: String, completion: @escaping (Result<[MixedMedia], Error>) -> Void) {
        // Construct the URL for the Reddit search based on the query
        var urlComponents = URLComponents(string: "\(baseRedditURL)/search")
        var queryItems = [URLQueryItem(name: "q", value: query)]
        urlComponents?.queryItems = queryItems

        guard let searchURL = urlComponents?.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        // Create a URLSession and make a data task to fetch the HTML content
        var request = URLRequest(url: searchURL)
        request.setValue("text/html", forHTTPHeaderField: "Accept")

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

                let subreddits = scrapeSubredditResults(data: doc)
//                let postsElement = try doc.select("div.listing search-result-listing").last()
                let posts = try parsePostData(data: data, trackingParamRemover: nil)
                // scrapePosts(data: doc, trackingParamRemover: nil)

                mixedMediaResults.append(contentsOf: subreddits.map { MixedMedia.subreddit($0) })
                mixedMediaResults.append(contentsOf: posts.map { MixedMedia.post($0, date: nil) })

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
}

