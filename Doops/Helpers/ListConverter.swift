//
//  ListConverter.swift
//  Doops
//
//  Created by Andrew Yakovlev on 6/17/23.
//

import Foundation

// Function to convert ShoppingList to JSON
func shoppingListToJSON(_ shoppingList: ShoppingList) -> Data? {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    do {
        let jsonData = try encoder.encode(shoppingList.products)
        return jsonData
    } catch {
        print("Error encoding ShoppingList to JSON: \(error.localizedDescription)")
        return nil
    }
}

// Function to convert JSON to ShoppingList
func shoppingListFromJSON(_ jsonData: Data) -> ShoppingList? {
    let decoder = JSONDecoder()
    do {
        let products = try decoder.decode([String: [Product]].self, from: jsonData)
        let shoppingList = ShoppingList()
        shoppingList.products = products
        return shoppingList
    } catch {
        print("Error decoding JSON to ShoppingList: \(error.localizedDescription)")
        return nil
    }
}

func tester() {
    
    if let jsonData = shoppingListToJSON(ShoppingList.shared) {
        // Print the JSON data as a string
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
        }
        
        // Convert JSON back to ShoppingList
        if let decodedShoppingList = shoppingListFromJSON(jsonData) {
            // Use the decoded ShoppingList
            print(decodedShoppingList.products)
        }
    }
    
}
