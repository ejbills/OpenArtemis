//
//  Misc Utils.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/8/23.
//

import Foundation
import SwiftUI

enum MixedMedia: Codable, Hashable {
    case post(Post, date: Date?)
    case comment(Comment, date: Date?)
    case subreddit(Subreddit)
    
    private enum CodingKeys: String, CodingKey {
        case type, content, date
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "post":
            let post = try container.decode(Post.self, forKey: .content)
            let date = try container.decodeIfPresent(Date.self, forKey: .date)
            self = .post(post, date: date)
        case "comment":
            let comment = try container.decode(Comment.self, forKey: .content)
            let date = try container.decodeIfPresent(Date.self, forKey: .date)
            self = .comment(comment, date: date)
        case "subreddit":
            let subreddit = try container.decode(Subreddit.self, forKey: .content)
            self = .subreddit(subreddit)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid type")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .post(let value, let date):
            try container.encode("post", forKey: .type)
            try container.encode(value, forKey: .content)
            try container.encodeIfPresent(date, forKey: .date)
        case .comment(let value, let date):
            try container.encode("comment", forKey: .type)
            try container.encode(value, forKey: .content)
            try container.encodeIfPresent(date, forKey: .date)
        case .subreddit(let value):
            try container.encode("subreddit", forKey: .type)
            try container.encode(value, forKey: .content)
        }
    }
}

class MiscUtils {
    static func shareItem(item: String, sourceView: UIView? = nil) {
        guard let url = URL(string: item) else { return }
        
        DispatchQueue.main.async {
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            
            // Set the source view for iPad
            if let popoverController = activityViewController.popoverPresentationController {
                popoverController.sourceView = sourceView ?? UIApplication.shared.windows.first
                popoverController.sourceRect = sourceView?.bounds ?? CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    static func openInBrowser(urlString: String) {
        DispatchQueue.main.async {
            if let url = URL(string: urlString) {
                SafariHelper.openSafariView(withURL: url)
            }
        }
    }
    
    static func showAlert(message: String, title: String = "Alert", completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completion?()
            })
            
            if let topViewController = UIApplication.shared.windows.first?.rootViewController {
                topViewController.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    static func extractMediaId(from media: MixedMedia) -> String {
        switch media {
        case .post(let post, _):
            return post.id
        case .comment(let comment, _):
            return comment.id
        case .subreddit(let subreddit):
            return subreddit.subreddit
        }
    }
}
