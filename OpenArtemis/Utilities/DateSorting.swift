//
//  MixedMediaSorting.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/27/23.
//

import Foundation

class DateSortingUtils {
    static func sortMixedMediaByDateDescending(_ mixedMediaLinks: inout [MixedMedia]) {
        mixedMediaLinks.sort { (lhs: MixedMedia, rhs: MixedMedia) -> Bool in
            var localDate1: Date
            var localDate2: Date

            switch lhs {
            case .post(_, let date), .comment(_, let date):
                localDate1 = date ?? Date()
            default:
                localDate1 = Date()
            }

            switch rhs {
            case .post(_, let date), .comment(_, let date):
                localDate2 = date ?? Date()
            default:
                localDate2 = Date()
            }

            return localDate1 > localDate2
        }
    }
}
