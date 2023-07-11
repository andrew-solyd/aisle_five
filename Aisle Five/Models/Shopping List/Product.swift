//
//  Product.swift
//  Doops
//
//  Created by Andrew Yakovlev on 6/20/23.
//

import Foundation
import Combine

// Define a new Product struct
class Product: Identifiable, ObservableObject, Codable {
    let id = UUID()
    var name: String
    var category: String
    
    @Published var isChecked: Bool = false {
       didSet {
           self.notifyListChanged()
       }
    }
    
    weak var shoppingList: ShoppingList?
    
    enum CodingKeys: String, CodingKey {
        case name
        case category
        case isChecked
    }
    
    init(name: String, category: String) {
        self.name = name
        self.category = category
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.category = try container.decode(String.self, forKey: .category)
        self.isChecked = try container.decode(Bool.self, forKey: .isChecked)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encode(isChecked, forKey: .isChecked)
    }
    
    func notifyListChanged() {
        shoppingList?.saveToFile()
    }
}
