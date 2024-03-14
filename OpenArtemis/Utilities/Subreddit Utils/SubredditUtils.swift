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
        
        PersistenceController.shared.save()
    }
    
    // Toggle pinned status of subreddit
    func togglePinned(managedObjectContext: NSManagedObjectContext, subredditName: String) {
        let matchingSubreddits = localFavorites(managedObjectContext: managedObjectContext).filter { $0.name == subredditName }
        
        matchingSubreddits.forEach { $0.pinned.toggle() }
        
        PersistenceController.shared.save()
    }
    
    // Toggle multi association of subreddit
    func toggleMulti(managedObjectContext: NSManagedObjectContext, multiName: String, subredditName: String) {
        let matchingSubreddits = localFavorites(managedObjectContext: managedObjectContext).filter { $0.name == subredditName }
        
        if let existingSubreddit = matchingSubreddits.first {
            existingSubreddit.belongsToMulti = existingSubreddit.belongsToMulti == multiName ? "" : multiName
            
            PersistenceController.shared.save()
        }
    }
    
    // Remove subreddit from favorites
    func removeFromSubredditFavorites(managedObjectContext: NSManagedObjectContext, subredditName: String) {
        let matchingSubreddits = localFavorites(managedObjectContext: managedObjectContext).filter { $0.name == subredditName }
        
        matchingSubreddits.forEach { managedObjectContext.delete($0) }
        
        PersistenceController.shared.save()
    }
    
    // Append subreddit icon to LocalSubreddit
    func fetchIconURL(managedObjectContext: NSManagedObjectContext, subredditName: String) {
        RedditScraper.scrapeSubredditIcon(subreddit: subredditName, completion: { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let iconURLString):
                    self.setIconURL(subredditName: subredditName, managedObjectContext: managedObjectContext, iconURLString: iconURLString)
                case .failure(let error):
                    if !Defaults[.seenCaseSensitiveDisclaimer] {
                        let message = "The fetch icon operation failed, possibly due to a case sensitivity mismatch between the subreddit name stored locally and its name on Reddit. Please ensure the subreddit name exactly matches its case on Reddit for the fetch to succeed."
                        MiscUtils.showAlert(message: message)
                        
                        Defaults[.seenCaseSensitiveDisclaimer] = true
                    }
                    
                    print("Failed to fetch url for subreddit: \(error)")
                }
            }
        })
    }
    
    // remove subreddit icon from LocalSubreddit
    func deleteIconURL(managedObjectContext: NSManagedObjectContext, subredditName: String){
        setIconURL(subredditName: subredditName, managedObjectContext: managedObjectContext, iconURLString: nil)
    }
    
    // Extract this as a function to avoid code duplication
    private func setIconURL(subredditName: String, managedObjectContext: NSManagedObjectContext, iconURLString: String?){
        // Assuming LocalSubreddit has a property called iconURL to store the icon URL string
        let cleanedName = self.cleanName(subredditName)
        // Fetch the LocalSubreddit object by name
        let fetchRequest: NSFetchRequest<LocalSubreddit> = LocalSubreddit.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", cleanedName)
        
        do {
            let fetchedSubreddits = try managedObjectContext.fetch(fetchRequest)
            guard let subredditToUpdate = fetchedSubreddits.first else {
                print("Subreddit not found")
                return
            }
            
            // Set the iconURL property
            subredditToUpdate.iconURL = iconURLString
            
            PersistenceController.shared.save()
            
        } catch {
            print("Error fetching subreddit data: \(error.localizedDescription)")
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
            
            PersistenceController.shared.save()
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
            
            PersistenceController.shared.save()
        } catch {
            print("Error removing multi: \(error.localizedDescription)")
        }
    }
    
    func editMulti(managedObjectContext: NSManagedObjectContext, oldMultiName: String, newMultiName: String, newImageURL: String) {
        // Step 1: Fetch and update the LocalMulti object
        let multiFetchRequest: NSFetchRequest<LocalMulti> = LocalMulti.fetchRequest()
        multiFetchRequest.predicate = NSPredicate(format: "multiName == %@", oldMultiName)

        do {
            let fetchedMultis = try managedObjectContext.fetch(multiFetchRequest)
            if let multiToUpdate = fetchedMultis.first {
                multiToUpdate.multiName = newMultiName
                multiToUpdate.imageURL = newImageURL
            }
        } catch {
            print("Error fetching or updating multireddit: \(error.localizedDescription)")
        }

        // Step 2: Fetch and update associated LocalSubreddit objects
        let subredditFetchRequest: NSFetchRequest<LocalSubreddit> = LocalSubreddit.fetchRequest()
        subredditFetchRequest.predicate = NSPredicate(format: "belongsToMulti == %@", oldMultiName)

        do {
            let fetchedSubreddits = try managedObjectContext.fetch(subredditFetchRequest)
            fetchedSubreddits.forEach { subreddit in
                subreddit.belongsToMulti = newMultiName // Update the belongsToMulti to newMultiName
            }
        } catch {
            print("Error fetching or updating associated subreddits: \(error.localizedDescription)")
        }

        // Save the changes
        PersistenceController.shared.save()
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
    
    // MARK: - Sorting Menu
    
    /// Builds the sorting menu for subreddit sorting options.
    ///
    /// - Parameter action: A closure to be executed upon selecting a sorting option.
    /// - Returns: The selected sorting option.
    func buildSortingMenu(selectedOption: SortOption, action: @escaping (SortOption) -> Void) -> some View {
        let sortMenuView = Menu(content: {
            ForEach(SortOption.allCases) { opt in
                if case .top(_) = opt {
                    Menu {
                        ForEach(SortOption.TopListingSortOption.allCases, id: \.self) { topOpt in
                            Button {
                                action(.top(topOpt))
                            } label: {
                                HStack {
                                    Text(topOpt.rawValue.capitalized)
                                    Spacer()
                                    Image(systemName: topOpt.icon)
                                        .foregroundColor(Color.artemisAccent)
                                        .font(.system(size: 17, weight: .bold))
                                }
                            }
                        }
                    } label: {
                        Label(opt.rawVal.value.capitalized, systemImage: opt.rawVal.icon)
                            .foregroundColor(Color.artemisAccent)
                            .font(.system(size: 17, weight: .bold))
                    }
                } else {
                    Button {
                        action(opt)
                    } label: {
                        HStack {
                            Text(opt.rawVal.value.capitalized)
                            Spacer()
                            Image(systemName: opt.rawVal.icon)
                                .foregroundColor(Color.artemisAccent)
                                .font(.system(size: 17, weight: .bold))
                        }
                    }
                }
            }
        }, label: {
            Image(systemName: selectedOption.rawVal.icon)
                .foregroundColor(Color.artemisAccent)
        })
        
        return sortMenuView
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
