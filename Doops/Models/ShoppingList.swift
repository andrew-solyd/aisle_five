//
//  ShoppingList.swift
//  Doops
//
//  Created by Andrew Yakovlev on 5/25/23.
//

import Combine

class ShoppingList: ObservableObject {
    static let shared = ShoppingList()
    
    @Published var products: [String: [Product]] = [:]
    
    // Add this function to your ShoppingList class
    func updateShoppingList(with sortedItems: [SortedItem]) {
        // Remove 'To Sort' items from products
        products["To Sort"] = nil

        // Add each sortedItem to its corresponding category
        for item in sortedItems {
            let product = Product(name: item.product, category: item.storeLocation)
            
            if products[item.storeLocation] == nil {
                products[item.storeLocation] = [product]
            } else {
                products[item.storeLocation]?.append(product)
            }
        }
    }
    
}
