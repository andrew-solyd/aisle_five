//
//  ContentView.swift
//  Doops
//
//  Created by Andrew Yakovlev on 5/1/23.
//

import SwiftUI

struct Message: Equatable {
    var text: String
    var isUserInput: Bool
}

extension Color {
    static let systemFontColor = Color(red: 22/255, green: 42/255, blue: 59/255)
    static let bodyColor = Color(red: 228 / 255, green: 234 / 255, blue: 240 / 255)
    static let userFontColor = Color(red: 22/255, green: 42/255, blue: 59/255, opacity: 0.65)
}

struct ContentView: View {
    
    @StateObject private var userSession = UserSession()
    @StateObject private var shoppingList = ShoppingList.shared
        
    let copilotManager = CopilotManager()
    
    @State private var isLoading = true    
    @State private var isShowingShoppingList = false
    
    var body: some View {
        NavigationView {
            if isLoading {
                LoadingView(isLoading: $isLoading)
            } else if isShowingShoppingList {
                ShoppingListView(isShowingShoppingList: $isShowingShoppingList)
                    .environmentObject(ShoppingList.shared)
            } else {
                VStack {
                    ConversationView(copilotManager: copilotManager,
                                     isShowingShoppingList: $isShowingShoppingList)
                    .environmentObject(ShoppingList.shared)
                    .environmentObject(userSession)
                }
                .background(Color.bodyColor)
            }
        }
        .background(Color.bodyColor.edgesIgnoringSafeArea(.all))
    }
}
