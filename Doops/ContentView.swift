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
    static let textColor = Color(red: 15 / 255, green: 43 / 255, blue: 61 / 255)
    static let bodyColor = Color(red: 229 / 255, green: 231 / 255, blue: 235 / 255)
    static let userColor = Color(red: 0.92, green: 0.93, blue: 0.73)
    static let aiColor = Color(red: 200 / 255, green: 231 / 255, blue: 235 / 255)
    
}

struct ContentView: View {
    
    let accountLinkingManager = AccountLinkingManager()
    let _userMessage = userMessage()
    
    @State private var textFieldText = ""
    @State private var userInput: String = ""
    @State private var conversation: [Message] = []
    @State var linkedRetailers: [NSNumber] = []
    @State var isLinked: Bool = false
    @State var isButtonDisabled = false
    @FocusState private var isFocused: Bool
    @State private var isWaitingForResponse: Bool = false
    @State private var dotCount: Int = 0
    @State private var waitingMessageIndex: Int? = nil
    @State var isUploaded: Bool = false
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    let semaphore = DispatchSemaphore(value: 1)
    
    var body: some View {
        VStack {
            ActionButtonView(conversation: $conversation,
                                     isLinked: $isLinked,
                                     isButtonDisabled: $isButtonDisabled,
                                     isUploaded: $isUploaded,
                                     accountLinkingManager: accountLinkingManager,
                                     _userMessage: _userMessage,
                                     semaphore: semaphore)
            ConversationView(conversation: $conversation)
            CustomTextEditorView(userInput: $userInput)
            Spacer()
            Spacer()
            UserInputButtonView(userInput: $userInput,
                                            isWaitingForResponse: $isWaitingForResponse,
                                            dotCount: $dotCount,
                                            conversation: $conversation,
                                            waitingMessageIndex: $waitingMessageIndex,
                                            _userMessage: _userMessage)                                            
        }
        .onAppear {
            let linkedRetailers = accountLinkingManager.getLinkedRetailers()
            if linkedRetailers.contains(52) {
                isLinked = true
            }
            _userMessage.resetAgent { result in
                    switch result {
                    case .success(let message):
                        DispatchQueue.main.async {
                            // Do something with the success message if needed
                            print(message)
                        }
                    case .failure(let error):
                        print("Error resetting agent: \(error.localizedDescription)")
                    }
                }
            isWaitingForResponse = true
            dotCount = 0
            waitingMessageIndex = conversation.endIndex
            conversation.append(Message(text: "", isUserInput: false))
            _userMessage.initializeAgent { result in
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
