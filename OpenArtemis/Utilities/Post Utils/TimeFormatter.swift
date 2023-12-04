//
//  TimeFormatter.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/3/23.
//

import Foundation

class TimeFormatUtil {
    func formatTimeAgo(fromUTCString utcString: String) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.allowsFractionalUnits = true
        
        let dateFormatter = ISO8601DateFormatter()
        if let date = dateFormatter.date(from: utcString) {
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: Date())
            
            if let formattedString = formatter.string(from: components) {
                return "\(formattedString) ago"
            } else {
                return "Unknown"
            }
        } else {
            return "Invalid Date"
        }
    }
}
