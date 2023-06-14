//
//  ShoppingList.swift
//  Doops
//
//  Created by Andrew Yakovlev on 5/25/23.
//

import SwiftUI
import Combine

// Define a new Product struct
struct Product: Identifiable {
    let id = UUID()
    var name: String
    var isChecked: Bool = false
}

class ShoppingList: ObservableObject {
    @Published var products: [Product] = ["Milk", "Eggs", "Bread", "Butter", "Apples",
                                         "Bananas", "Cheese", "Yogurt", "Orange Juice", "Cereal",
                                         "Coffee", "Tea", "Chicken", "Beef", "Fish",
                                         "Rice", "Pasta", "Olive Oil", "Flour", "Sugar",
                                         "Salt", "Pepper", "Tomatoes", "Potatoes", "Carrots",
                                         "Onions", "Garlic", "Spinach", "Broccoli", "Peas",
                                         "Bell Peppers", "Cucumbers", "Lettuce", "Zucchini",
                                         "Strawberries", "Blueberries"].map { Product(name: $0) }
}
