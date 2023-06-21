//
//  UpdateQueue.swift
//  Doops
//
//  Created by Andrew Yakovlev on 6/20/23.
//

import Foundation

class UpdateQueue {
    // Shared instance
    static let shared = UpdateQueue()

    // The queue of items to add
    private var queue: [SortedItem] = []
    private var timer: Timer?

    func addItem(_ item: SortedItem) {
        
        // Check if item already exists in the Shopping List "To Sort" category, if not ignore
        guard ShoppingList.shared.products["To Sort"]?.contains(where: { $0.name == item.product }) ?? false else {
            // If it does not exist in "To Sort", the guard condition fails and it comes here. In this case, we return from the function without doing anything else.
            return
        }
        // Add the item to the queue
        queue.append(item)

        // If the timer isn't already running, start it
        if timer == nil {
            DispatchQueue.main.async {
                self.timer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(self.processNextItem), userInfo: nil, repeats: true)
            }
        }
    }

    @objc private func processNextItem() {
        // If there are no items left, invalidate the timer
        guard !queue.isEmpty else {
            timer?.invalidate()
            timer = nil
            return
        }

        // Remove the first item from the queue and update the Shopping List
        let item = queue.removeFirst()
        DispatchQueue.main.async {
            ShoppingList.shared.updateShoppingList(with: [item])
        }
    }
}
