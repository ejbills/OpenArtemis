//
//  Misc Utils.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/8/23.
//

import Foundation
import SwiftUI

/// A generic enum representing either the first type `A` or the second type `B`.
enum Either<A: Codable & Hashable, B: Codable & Hashable>: Codable, Hashable {
    
    /// Represents the first type.
    case first(A)
    
    /// Represents the second type.
    case second(B)
    
    /// Initializes an instance by decoding from the given decoder.
    /// Throws a `DecodingError` if there is a type mismatch for both types.
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        do {
            let firstType = try container.decode(A.self)
            self = .first(firstType)
        } catch let firstError {
            do {
                let secondType = try container.decode(B.self)
                self = .second(secondType)
            } catch let secondError {
                let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Type mismatch for both types.", underlyingError: Swift.DecodingError.typeMismatch(Any.self, DecodingError.Context.init(codingPath: decoder.codingPath, debugDescription: "First type error: \(firstError). Second type error: \(secondError)")))
                throw DecodingError.dataCorrupted(context)
            }
        }
    }
    
    /// Encodes the instance to the given encoder.
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .first(let value):
            try container.encode(value)
        case .second(let value):
            try container.encode(value)
        }
    }
}

/// A struct representing a tuple containing a date and content of either a `Post` or a `Comment`.
struct MixedMediaTuple: Hashable {
    
    /// The date associated with the tuple.
    var date: Date
    
    /// The content of either a `Post` or a `Comment`.
    var content: Either<Post, Comment>
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
}
