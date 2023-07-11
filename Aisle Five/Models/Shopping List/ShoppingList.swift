//
//  ShoppingList.swift
//  Doops
//
//  Created by Andrew Yakovlev on 5/25/23.
//

import Combine
import Foundation

class ShoppingList: ObservableObject {
    static let shared = ShoppingList()
    
    @Published var products: [String: [Product]] = [:] {
        didSet {
            saveToFile()
        }
    }
        
    init() {
        let loadedProducts = self.loadFromFile()
        if let loaded = loadedProducts {
            self.products = loaded
        }
    }

    func saveToFile() {
        print("Saving list...")
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent("SavedShoppingList.json")
        do {
            let data = try JSONEncoder().encode(products)
            try data.write(to: fileURL)
        } catch {
            print("Failed to write data: \(error)")
        }
    }

    func loadFromFile() -> [String: [Product]]? {
        print("Loading list...")
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent("SavedShoppingList.json")
        do {
            let data = try Data(contentsOf: fileURL)
            let loadedShoppingList = try JSONDecoder().decode([String: [Product]].self, from: data)
            return loadedShoppingList
        } catch {
            print("Failed to read file: \(error)")
            return nil
        }
    }
    
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
    
    func toggleProductCheckStatus(product: Product) {
        for (category, products) in self.products {
            if let index = products.firstIndex(where: {$0.id == product.id}) {
                var newProduct = products[index] // make a copy of the product
                newProduct.isChecked = !newProduct.isChecked // toggle its isChecked status explicitly
                self.products[category]?[index] = newProduct // replace the original product with the new one
                break // Once you find the product, no need to continue the loop
            }
        }
        // At this point, you may want to persist the updated list to disk or cloud.
        saveToFile()
    }
}
