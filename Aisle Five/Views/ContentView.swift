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
        
    let conversationHistory = ConversationHistory()
    let copilotManager = CopilotManager()
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    @State private var isLoading = true
    @State private var isInitiliazied = false
    @State private var isTextEditorVisible = false
    @State private var textFieldText = ""
    @State private var userInput: String = ""
    @State private var conversation: [Message] = []
    @State private var isWaitingForResponse: Bool = false
    @State private var dotCount: Int = 0
    @State private var waitingMessageIndex: Int? = nil
    @State private var isShowingShoppingList = false
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            if isLoading {
                LoadingView(isLoading: $isLoading)
            } else if isShowingShoppingList {
                ShoppingListView(isShowingShoppingList: $isShowingShoppingList)
                    .environmentObject(ShoppingList.shared)
            } else {
                VStack {
                    ConversationView(conversation: $conversation,
                                     isWaitingForResponse: $isWaitingForResponse,
                                     dotCount: $dotCount,
                                     waitingMessageIndex: $waitingMessageIndex,
                                     isTextEditorVisible: $isTextEditorVisible,
                                     userInput: $userInput,
                                     isShowingShoppingList: $isShowingShoppingList)
                    .environmentObject(ShoppingList.shared)
                    .environmentObject(userSession)
                }
                .onAppear {
                    if !isInitiliazied {
                        // reset conversationHistory
                        conversationHistory.reset()
                        //
                        isWaitingForResponse = true
                        dotCount = 0
                        waitingMessageIndex = conversation.endIndex
                        conversation.append(Message(text: "", isUserInput: false))
                        copilotManager.initialize { result in
                            DispatchQueue.main.async {
                                if let index = self.waitingMessageIndex {
                                    conversation.remove(at: index)
                                    self.waitingMessageIndex = nil
                                }
                                switch result {
                                case .success(let message):
                                    DispatchQueue.main.async {
                                        conversation.append(Message(text: message, isUserInput: false))
                                    }
                                case .failure(let error):
                                    print("Error initializing agent: \(error.localizedDescription)")
                                }
                            }
                            isWaitingForResponse = false
                            isTextEditorVisible = true
                        }
                        isInitiliazied = true
                    }
                }
                .onReceive(timer) { _ in
                    if isWaitingForResponse {
                        // Check if the index is within the bounds of the array
                        if let index = self.waitingMessageIndex, index < conversation.count {
                            let dots = String(repeating: ".", count: dotCount)
                            conversation[index] = Message(text: " \(dots)", isUserInput: false)
                            dotCount = (dotCount + 1) % 4
                        } else {
                            // If the index is out of bounds, reset the waitingMessageIndex and start the animation over
                            waitingMessageIndex = nil
                            isWaitingForResponse = false
                        }
                    }
                }
                .background(Color.bodyColor)
            }
        }
        .background(Color.bodyColor.edgesIgnoringSafeArea(.all))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
