//
//  ShoppingList.swift
//  Doops
//
//  Created by Andrew Yakovlev on 5/25/23.
//

import SwiftUI
import Combine

// Define a new Product struct
class Product: Identifiable, ObservableObject {
    let id = UUID()
    var name: String
    var category: String
    @Published var isChecked: Bool = false
    
    init(name: String, category: String) {
        self.name = name
        self.category = category
    }
}

class ShoppingList: ObservableObject {
    static let shared = ShoppingList()
    
    @Published var products: [String: [Product]] = [
        "Dairy": ["Milk", "Eggs", "Butter", "Cheese", "Yogurt"].map { Product(name: $0, category: "Dairy") },
        "Produce": ["Apples", "Bananas", "Tomatoes", "Potatoes", "Carrots", "Onions", "Garlic", "Spinach", "Broccoli", "Peas", "Bell Peppers", "Cucumbers", "Lettuce", "Zucchini", "Strawberries", "Blueberries"].map { Product(name: $0, category: "Produce") },
        "Meats": ["Chicken", "Beef", "Fish"].map { Product(name: $0, category: "Meats") },
        "Bakery": ["Bread"].map { Product(name: $0, category: "Bakery") },
        "Pantry": ["Rice", "Pasta", "Olive Oil", "Flour", "Sugar", "Salt", "Pepper", "Cereal", "Coffee", "Tea"].map { Product(name: $0, category: "Pantry") },
        "Drinks": ["Orange Juice"].map { Product(name: $0, category: "Drinks") }
    ]
}
