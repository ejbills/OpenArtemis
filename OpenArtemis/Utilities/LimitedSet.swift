//
//  LimitedSet.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 1/2/24.
//

import Foundation

struct LimitedSet<T: Hashable> {
    private var storage: Set<T> = []
    private var order: [T] = []
    private let maxLength: Int

    init(maxLength: Int) {
        self.maxLength = maxLength
    }

    mutating func insert(_ item: T) {
        if storage.contains(item) {
            // Move the existing item to the front of the order
            if let index = order.firstIndex(of: item) {
                order.remove(at: index)
                order.insert(item, at: 0)
            }
        } else {
            // Insert the new item at the front of the order
            storage.insert(item)
            order.insert(item, at: 0)

            // If the set exceeds the maximum length, remove the oldest item
            if order.count > maxLength {
                let removedItem = order.removeLast()
                storage.remove(removedItem)
            }
        }
    }

    func contains(_ item: T) -> Bool {
        storage.contains(item)
    }

    func toArray() -> [T] {
        order
    }
    
    mutating func removeAll() {
        storage.removeAll()
        order.removeAll()
    }
}
