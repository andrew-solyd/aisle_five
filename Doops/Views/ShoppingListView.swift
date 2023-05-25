//
//  ShoppingListView.swift
//  Doops
//
//  Created by Andrew Yakovlev on 5/25/23.
//

import SwiftUI

struct ShoppingListView: View {
    @EnvironmentObject var shoppingList: ShoppingList
    
    var body: some View {
        VStack {
            Text("Shopping List")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Display the added items
            List(shoppingList.products, id: \.self) { product in
                Text(product)
            }
            
            Button(action: {
                // Here you need to implement navigation back to the main screen
                // In a NavigationView, you can use `navigation.popViewController(animated: true)`
            }) {
                Text("Back to chat")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bodyColor)
    }
}
