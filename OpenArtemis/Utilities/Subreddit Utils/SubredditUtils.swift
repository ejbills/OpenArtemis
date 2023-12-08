//
//  SubredditUtils.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/8/23.
//

import SwiftUI
import CoreData

class SubredditUtils: ObservableObject {
    static let shared = SubredditUtils()

    private init() {}

    func saveToSubredditFavorites(managedObjectContext: NSManagedObjectContext, name: String) {
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "^/r/", with: "", options: .regularExpression)
            .replacingOccurrences(of: "^r/", with: "", options: .regularExpression)

        let tempSubreddit = LocalSubreddit(context: managedObjectContext)
        tempSubreddit.name = cleanedName

        withAnimation(.snappy) {
            PersistenceController.shared.save()
        }
    }

    func removeFromSubredditFavorites(managedObjectContext: NSManagedObjectContext, subredditName: String) {
        let matchingSubreddits = localFavorites(managedObjectContext: managedObjectContext).filter { $0.name == subredditName }

        for subreddit in matchingSubreddits {
            managedObjectContext.delete(subreddit)
        }

        withAnimation(.snappy) {
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
