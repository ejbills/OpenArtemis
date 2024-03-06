//
//  SubredditUtils.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/8/23.
//

import SwiftUI
import CoreData
import Defaults

// MARK: - Subreddit and SubredditUtils

struct Subreddit: Encodable, Equatable, Hashable, Decodable {
    let subreddit: String
}

class SubredditUtils: ObservableObject {
    static let shared = SubredditUtils()

    private init() {}

    // MARK: - Subreddit Favorites Operations

    // Save subreddit to favorites
    func saveToSubredditFavorites(managedObjectContext: NSManagedObjectContext, name: String) {
        let cleanedName = cleanName(name)
        guard !subredditAlreadySaved(managedObjectContext: managedObjectContext, subredditName: cleanedName) else {
            return
        }

        let tempSubreddit = LocalSubreddit(context: managedObjectContext)
        tempSubreddit.name = cleanedName

        withAnimation(.smooth) {
            PersistenceController.shared.save()
        }
    }

    // Toggle pinned status of subreddit
    func togglePinned(managedObjectContext: NSManagedObjectContext, subredditName: String) {
        let matchingSubreddits = localFavorites(managedObjectContext: managedObjectContext).filter { $0.name == subredditName }

        matchingSubreddits.forEach { $0.pinned.toggle() }

        withAnimation(.smooth) {
            PersistenceController.shared.save()
        }
    }

    // Toggle multi association of subreddit
    func toggleMulti(managedObjectContext: NSManagedObjectContext, multiName: String, subredditName: String) {
        let matchingSubreddits = localFavorites(managedObjectContext: managedObjectContext).filter { $0.name == subredditName }

        if let existingSubreddit = matchingSubreddits.first {
            existingSubreddit.belongsToMulti = existingSubreddit.belongsToMulti == multiName ? "" : multiName

            withAnimation(.smooth) {
                PersistenceController.shared.save()
            }
        }
    }

    // Remove subreddit from favorites
    func removeFromSubredditFavorites(managedObjectContext: NSManagedObjectContext, subredditName: String) {
        let matchingSubreddits = localFavorites(managedObjectContext: managedObjectContext).filter { $0.name == subredditName }

        matchingSubreddits.forEach { managedObjectContext.delete($0) }

        withAnimation(.smooth) {
            PersistenceController.shared.save()
        }
    }

    // MARK: - Multireddit Operations

    // Save multireddit
    func saveToMultis(managedObjectContext: NSManagedObjectContext, name: String, imageURL: String) {
        guard !multiAlreadySaved(managedObjectContext: managedObjectContext, multiName: name) else {
            return
        }

        if !name.isEmpty {
            let tempMulti = LocalMulti(context: managedObjectContext)
            tempMulti.multiName = name

            if !imageURL.isEmpty {
                tempMulti.imageURL = imageURL
            }

            withAnimation(.smooth) {
                PersistenceController.shared.save()
            }
        }
    }

    // Remove multireddit
    func removeFromMultis(managedObjectContext: NSManagedObjectContext, multiName: String) {
        let fetchRequest: NSFetchRequest<LocalSubreddit> = LocalSubreddit.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "belongsToMulti == %@", multiName)

        do {
            let matchingSubreddits = try managedObjectContext.fetch(fetchRequest)
            matchingSubreddits.forEach { subreddit in
                subreddit.belongsToMulti = nil
            }

            localMultis(managedObjectContext: managedObjectContext)
                .filter { $0.multiName == multiName }
                .forEach { managedObjectContext.delete($0) }

            withAnimation(.smooth) {
                PersistenceController.shared.save()
            }
        } catch {
            print("Error removing multi: \(error.localizedDescription)")
        }
    }

    // MARK: - Helper Functions

    // Retrieve local favorites
    func localFavorites(managedObjectContext: NSManagedObjectContext) -> [LocalSubreddit] {
        do {
            return try managedObjectContext.fetch(LocalSubreddit.fetchRequest())
        } catch {
            return []
        }
    }

    // Retrieve local multireddits
    func localMultis(managedObjectContext: NSManagedObjectContext) -> [LocalMulti] {
        do {
            return try managedObjectContext.fetch(LocalMulti.fetchRequest())
        } catch {
            return []
        }
    }

    // Retrieve subreddits associated with a multi
    func subsAssociatedWithMulti(managedObjectContext: NSManagedObjectContext, multiName: String) -> [String] {
        let fetchRequest: NSFetchRequest<LocalSubreddit> = LocalSubreddit.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "belongsToMulti == %@", multiName)

        do {
            let tempResults = try managedObjectContext.fetch(fetchRequest)
            return tempResults.map { $0.name ?? "" }
        } catch {
            return []
        }
    }

    // Retrieve multi associated with a subreddit
    func getMultiFromSub(managedObjectContext: NSManagedObjectContext, subredditName: String) -> String? {
        let fetchRequest: NSFetchRequest<LocalSubreddit> = LocalSubreddit.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", subredditName)

        do {
            let tempResults = try managedObjectContext.fetch(fetchRequest)
            return tempResults.first?.belongsToMulti
        } catch {
            return nil
        }
    }

    // MARK: - Private Helpers

    // Check if subreddit is already saved
    private func subredditAlreadySaved(managedObjectContext: NSManagedObjectContext, subredditName: String) -> Bool {
        let existingSubreddits = localFavorites(managedObjectContext: managedObjectContext)
        return existingSubreddits.contains { $0.name == subredditName }
    }

    // Check if multireddit is already saved
    private func multiAlreadySaved(managedObjectContext: NSManagedObjectContext, multiName: String) -> Bool {
        let existingMultis = localMultis(managedObjectContext: managedObjectContext)
        return existingMultis.contains { $0.multiName == multiName }
    }

    // Clean subreddit name
    private func cleanName(_ name: String) -> String {
        return name.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "^/r/", with: "", options: .regularExpression)
            .replacingOccurrences(of: "^r/", with: "", options: .regularExpression)
    }
}

// MARK: - SubListingSort and SortOption

struct SubListingSort: Codable, Identifiable {
    var icon: String
    var value: String

    var id: String { value }
}

enum SortOption: Codable, Identifiable, Defaults.Serializable, Hashable {
    var id: String { rawVal.id }

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

    static var allCases: [SortOption] {
        return [.best, .hot, .new, .controversial, .top(.all)]
    }
}
