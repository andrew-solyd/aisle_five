//
//  AisleFiveApp.swift
//  AisleFive
//
//  Created by Andrew Yakovlev on 5/1/23.
//

import SwiftUI

@main
struct DoopsApp: App {
    @StateObject private var shoppingList = ShoppingList()
    let persistenceController = PersistenceController.shared
    
    init() {
        print("I'm alive!")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(shoppingList)
                .onOpenURL { url in
                    if url.scheme == "product", let product = url.host {
                        // Add product to the shopping list with the category determined by your GPT API
                        // As a placeholder, let's use the "To Sort" category
                        shoppingList.products["To Sort"]?.append(Product(name: product, category: "To Sort"))
                    }
                }
        }
    }
}
