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
            
            if !isLinked {
                Button(action: {
                    conversation.append(Message(text: "Linking account stand by...", isUserInput: false))
                    accountLinkingManager.linkToRetailer { success, message in
                        if success {
                            conversation.append(Message(text: "Successfully linked account!", isUserInput: false))
                            isLinked = true
                        } else {
                            conversation.append(Message(text: message, isUserInput: false))
                        }
                        isButtonDisabled = false
                    }
                    isButtonDisabled = true
                }) {
                    Text("Link my account")
                        .foregroundColor(.black)
                        .frame(minWidth: 120)
                        .font(.system(size: 12))
                }
                .buttonStyle(BorderedButtonStyle())
                .border(Color.gray, width: 0.2)
                .disabled(isButtonDisabled)
            } else {
                Button(action: {
                    conversation.append(Message(text: "Extracting and syncing your purchase data.", isUserInput: false))
                    // action
                    accountLinkingManager.updateConnectionAndGrabOrders { (retailer, jsonString, ordersRemaining, viewController, error, sessionId) in
                        
                        // Try to acquire a permit. If none are available, this call will block until one becomes available.
                        semaphore.wait()
                        
                        if error == .none && !isUploaded {
                            if let jsonString = jsonString {
                                _userMessage.uploadPurchaseHistory(jsonString: jsonString) { (result) in
                                    switch result {
                                    case .success(let response):
                                        if !response.isEmpty {
                                            conversation.append(Message(text: response, isUserInput: false))
                                            isUploaded = true
                                        }
                                    case .failure(let error):
                                        conversation.append(Message(text: "Failed to upload purchase history with error: \(error.localizedDescription)", isUserInput: false))
                                    }
                                    // Release the permit back to the semaphore, unblocking a waiting `wait()` call if there is one.
                                    semaphore.signal()
                                }
                            } else {
                                print("nil order data, skipping")
                                semaphore.signal()
                            }
                        } else {
                            conversation.append(Message(text: "Error encountered while grabbing orders.", isUserInput: false))
                            print(error)
                            semaphore.signal()
                        }
                    }
                }) {
                    Text("Sync my data")
                        .foregroundColor(.black)
                        .frame(minWidth: 120)
                        .font(.system(size: 12))
                }
                .buttonStyle(BorderedButtonStyle())
                .border(Color.gray, width: 0.2)
                .disabled(isUploaded)
            }
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(conversation.indices, id: \.self) { index in
                            let message = conversation[index].text
                            let isUserInput = conversation[index].isUserInput
                            VStack {
                                Text(message)
                                    .foregroundColor(.textColor)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(isUserInput ? Color.userColor : Color.aiColor)
                                    //.cornerRadius(8)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: 16))
                                    .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 2, y: 2)
                            }
                        }
                    }
                    .padding()
                    .frame(maxHeight: .infinity)
                    .onChange(of: conversation) { _ in
                        let bottom = conversation.indices.last ?? 0
                        scrollViewProxy.scrollTo(bottom, anchor: .bottom)
                    }
                }
            }
            TextEditor(text: $userInput)
                .font(.custom("Parclo", size: 16))
                .foregroundColor(.textColor)
                .frame(height: 80)
                .padding(.horizontal)
                // .background(Color.clear)
                .overlay(
                    Text(userInput.isEmpty && !isFocused ? "Enter GPT prompt here" : "")
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                )
                .focused($isFocused)
                .onTapGesture {
                    isFocused = true
                }
            Spacer()
            Spacer()
            Button {
                if !userInput.isEmpty {
                    isWaitingForResponse = true
                    dotCount = 0
                    conversation.append(Message(text: userInput, isUserInput: true))
                    waitingMessageIndex = conversation.endIndex
                    conversation.append(Message(text: " ", isUserInput: false))
                    _userMessage.sendRequest(with: userInput) { result in
                        switch result {
                        case .success(let response):
                            DispatchQueue.main.async {
                                if let index = self.waitingMessageIndex {
                                    conversation.remove(at: index)
                                    self.waitingMessageIndex = nil
                                }
                                let trimmedResponse = response.trimmingCharacters(in: .whitespacesAndNewlines) // Remove newline character from response
                                
                                // Check for "#getDeals" in the response
                                if let range = trimmedResponse.range(of: "#getDeals") {
                                    let messageWithoutSystemCommand = String(trimmedResponse[..<range.lowerBound])
                                    DispatchQueue.main.async {
                                        conversation.append(Message(text: messageWithoutSystemCommand, isUserInput: false))
                                    }
                                    // Call getDeals API
                                    isWaitingForResponse = true
                                    dotCount = 0
                                    waitingMessageIndex = conversation.endIndex
                                    conversation.append(Message(text: "", isUserInput: false))
                                    _userMessage.getDeals { result in
                                        DispatchQueue.main.async {
                                            if let index = self.waitingMessageIndex {
                                                conversation.remove(at: index)
                                                self.waitingMessageIndex = nil
                                            }
                                            switch result {
                                            case .success(let dealsMessage):
                                                DispatchQueue.main.async {
                                                    conversation.append(Message(text: dealsMessage, isUserInput: false))
                                                }
                                            case .failure(let error):
                                                print("Error getting deals: \(error.localizedDescription)")
                                            }
                                        }
                                        isWaitingForResponse = false
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        conversation.append(Message(text: trimmedResponse, isUserInput: false))
                                    }
                                    isWaitingForResponse = false
                                }
                            }
                        case .failure(let error):
                            DispatchQueue.main.async {
                                if let index = self.waitingMessageIndex {
                                    conversation.remove(at: index)
                                    self.waitingMessageIndex = nil
                                }
                                conversation.append(Message(text: error.localizedDescription, isUserInput: false))
                            }
                            isWaitingForResponse = false
                        }
                    }
                    userInput = ""
                }
            }
            label: {
                Image(systemName: "paperplane.fill")
            }
            .disabled(userInput.isEmpty)
            .accentColor(userInput.isEmpty ? .gray : .textColor)
            Spacer(minLength: 10)
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
