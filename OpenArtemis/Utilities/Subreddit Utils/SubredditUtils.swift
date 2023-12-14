//
//  SubredditUtils.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/8/23.
//

import SwiftUI
import CoreData
import Defaults

class SubredditUtils: ObservableObject {
    static let shared = SubredditUtils()

    private init() {}

    func saveToSubredditFavorites(managedObjectContext: NSManagedObjectContext, name: String) {
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "^/r/", with: "", options: .regularExpression)
            .replacingOccurrences(of: "^r/", with: "", options: .regularExpression)

        let tempSubreddit = LocalSubreddit(context: managedObjectContext)
        tempSubreddit.name = cleanedName

        withAnimation(.smooth) {
            PersistenceController.shared.save()
        }
    }

    func removeFromSubredditFavorites(managedObjectContext: NSManagedObjectContext, subredditName: String) {
        let matchingSubreddits = localFavorites(managedObjectContext: managedObjectContext).filter { $0.name == subredditName }

        for subreddit in matchingSubreddits {
            managedObjectContext.delete(subreddit)
        }

        withAnimation(.smooth) {
            PersistenceController.shared.save()
        }
    }

    func localFavorites(managedObjectContext: NSManagedObjectContext) -> [LocalSubreddit] {
        do {
            return try managedObjectContext.fetch(LocalSubreddit.fetchRequest())
        } catch {
            return []
        }
    }
}

struct SubListingSort: Codable, Identifiable {
    var icon: String
    var value: String
    var id: String {
        value
    }
}

enum SubListingSortOption: Codable, Identifiable, Defaults.Serializable, Hashable {
    var id: String {
        self.rawVal.id
    }

    case best
    case hot
    case new
    case controversial
    case top(TopListingSortOption)

    enum TopListingSortOption: String, Codable, CaseIterable, Hashable {
        case hour
        case day
        case week
        case month
        case year
        case all

        var icon: String {
            switch self {
            case .hour: return "clock"
            case .day: return "sun.max"
            case .week: return "clock.arrow.2.circlepath"
            case .month: return "calendar"
            case .year: return "globe.americas.fill"
            case .all: return "arrow.up.circle.badge.clock"
            }
        }
    }

    var rawVal: SubListingSort {
        switch self {
        case .best: return SubListingSort(icon: "trophy", value: "best")
        case .controversial: return SubListingSort(icon: "figure.fencing", value: "controversial")
        case .hot: return SubListingSort(icon: "flame", value: "hot")
        case .new: return SubListingSort(icon: "newspaper", value: "new")
        case .top(let subOption):
            if subOption == .all {
                return SubListingSort(icon: subOption.icon, value: "top")
            } else {
                return SubListingSort(icon: subOption.icon, value: "top/\(subOption.rawValue)")
            }
        }
    }
}

extension SubListingSortOption: CaseIterable {
    static var allCases: [SubListingSortOption] {
        return [.best, .hot, .new, .controversial, .top(.all)]
    }
}
