//
//  ShoppingList.swift
//  Doops
//
//  Created by Andrew Yakovlev on 5/25/23.
//

import SwiftUI
import Combine

class ShoppingList: ObservableObject {
    @Published var products: [String] = []
}
