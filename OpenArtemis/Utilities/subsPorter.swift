//
//  subsPorter.swift
//  OpenArtemis
//
//  Created by daniel on 04/12/23.
//

import Foundation
import CoreData
import SwiftUI

func exportSubs(fileName: String, subreddits: [String]) -> String? {

    do {
        // Create a dictionary with a key for the array
        let subsDictionary = ["subbed_subreddits": subreddits]

        // Serialize the dictionary as JSON data
        let jsonData = try JSONSerialization.data(withJSONObject: subsDictionary, options: .prettyPrinted)

        // Define the file URL where you want to save the JSON file
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(fileName)

            // Write the JSON data to the file
            try jsonData.write(to: fileURL)

            print("Subreddits exported to: \(fileURL.absoluteString)")
            return fileURL.absoluteString
        }
    } catch {
        print("Error exporting UserDefaults to JSON: \(error)")
    }

    return nil
}

func importSubreddits(jsonFilePath: URL) -> Bool {
  // Check if the file exists at the provided path
  let gotAccess = jsonFilePath.startAccessingSecurityScopedResource()
  if !gotAccess {
    print("Can't get file access")
    return false
  }
  do {
    // Read the JSON data from the file
    let jsonData = try Data(contentsOf:jsonFilePath)
    
    // Deserialize the JSON data into a dictionary
    if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {

        for subreddit in jsonObject["subbed_subreddits"] as! [String]{
            let tempSubreddit = LocalSubreddit(context: PersistenceController.shared.container.viewContext)
            tempSubreddit.name = subreddit
        }
      
        PersistenceController.shared.save()
      
      print("Subreddits imported from: \(jsonFilePath)")
      jsonFilePath.stopAccessingSecurityScopedResource()
      return true
    }
  } catch {
    print("Error importing Subreddits from JSON: \(error)")
    jsonFilePath.stopAccessingSecurityScopedResource()
  }
  return false
}
