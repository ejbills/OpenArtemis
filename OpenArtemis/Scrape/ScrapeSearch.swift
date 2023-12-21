//
//  ScrapeSearch.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/21/23.
//

import Foundation
import SwiftSoup

extension RedditScraper {
    static func search(query: String, completion: @escaping (Result<Void, Error>) -> Void) {
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

                // Call hypothetical methods
                // Uncomment and implement these methods as needed
                // scrapeSubredditResults(data: doc, trackingParamRemover: nil)
                // scrapePosts(data: doc, trackingParamRemover: nil)

                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

