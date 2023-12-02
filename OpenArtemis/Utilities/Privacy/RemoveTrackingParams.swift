//
//  RemoveTrackingParams.swift
//  OpenArtemis
//
//  Created by daniel on 02/12/23.
//

import Foundation
import Defaults

class TrackingParamRemover: ObservableObject, Observable{
  private let trackingListURL = "https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/TrackParamFilter/sections/general_url.txt"
  private var trackingList: [String] = []
  private let trackingListFileName = "trackingList.txt"
  
  public var trackinglistLength: Int {
    return trackingList.count
  }
  
  init() {
    loadTrackingList()
  }
  
  
  func cleanURL(_ url: URL) -> URL {
    guard !trackingList.isEmpty else {
      return url
    }
    
    var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
    guard var queryItems = components?.queryItems else {
      return url
    }
    
    queryItems = queryItems.filter { queryItem in
      return !trackingList.contains { trackingParam in
        return queryItem.name.lowercased() == trackingParam.lowercased()
      }
    }
    
    components?.queryItems = queryItems.isEmpty ? nil : queryItems
    
    if let cleanedURL = components?.url {
      return cleanedURL
    } else {
      return url
    }
  }
  
  
  func unloadTrackingList(){
    self.trackingList = []
  }
  
  //For abstraction and maintainability purposes this is a separate function
  func updateTrackingList(completion: @escaping (Bool) -> Void){
    self.downloadTrackingList{ res in
      completion(res)
    }
  }
  
  func loadTrackingList() {
    let fileURL = getTrackingListFileURL()
    
    do {
      let contents = try String(contentsOf: fileURL, encoding: .utf8)
      trackingList = contents.components(separatedBy: .newlines)
        .map {
          $0.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "$removeparam=", with: "")
        }
        .filter { !$0.isEmpty && !$0.contains("!")}
    } catch {
      print("Error loading tracking list from file: \(error.localizedDescription)")
      downloadTrackingList{ completion in
        //Do nothing
      }
    }
  }
  
  private func downloadTrackingList(completion: @escaping (Bool) -> Void){
    let fileLocation = getTrackingListFileURL()
    
    guard let url = URL(string: trackingListURL) else {
      print("Invalid tracking list URL")
      return
    }
    
    let sessionConfig = URLSessionConfiguration.default
    let session = URLSession(configuration: sessionConfig)
    let request = URLRequest(url: url)
    
    let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
      if let tempLocalUrl = tempLocalUrl, error == nil {
        // Success
        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
          self.loadTrackingList()
          completion(true)
        }
        
        // Remove existing file
        do {
          try FileManager.default.removeItem(at: fileLocation)
        } catch {
          print("Error removing existing file: \(error.localizedDescription)")
        }
        
        do {
          try FileManager.default.copyItem(at: tempLocalUrl, to: fileLocation)
          
        } catch (let writeError) {
          print("error writing file \(fileLocation) : \(writeError)")
          completion(false)
        }
        
      } else {
        print("Failure: %@", error!.localizedDescription);
        completion(false)
      }
    }
    task.resume()
    completion(false)
  }
  
  private func getTrackingListFileURL() -> URL {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    return documentsDirectory.appendingPathComponent(trackingListFileName)
  }
}
