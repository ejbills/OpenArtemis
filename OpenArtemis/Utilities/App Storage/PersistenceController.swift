//
//  PersistenceController.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/2/23.
//

import CoreData
import SwiftUI

struct PersistenceController {
    // A singleton for our entire app to use
    static let shared = PersistenceController()

    // Storage for Core Data
    let container: NSPersistentContainer

    // An initializer to load Core Data, optionally able
    // to use an in-memory store.
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "LocalData")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        guard container.persistentStoreDescriptions.first != nil else {
            fatalError("Failed to init persistent container")
        }

        // Enable lightweight migration options
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]

        do {
            try container.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: container.persistentStoreDescriptions.first!.url, options: options)
        } catch {
            fatalError("Error adding persistent store: \(error)")
        }
    }
    
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try withAnimation(.smooth) { try context.save() }
            } catch {
                print("Failed to save to persistent storage.")
            }
        }
    }
}
