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

struct ContentView: View {
    
    @State private var textFieldText = ""
    @State private var userInput: String = ""
    @State private var conversation: [Message] = []
    @State var linkedRetailers: [NSNumber] = []
    @State var isLinked: Bool = false
    @State var isButtonDisabled = false
    @FocusState private var isFocused: Bool
    
    let accountLinkingManager = AccountLinkingManager()
    let _userMessage = userMessage()
    
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
                        .font(.system(size: 14))
                }
                .buttonStyle(BorderedButtonStyle())
                .border(Color.gray, width: 1.0)
                .disabled(isButtonDisabled)
            } else {
                Button(action: {
                    conversation.append(Message(text: "Extracting and syncing your purchase data.", isUserInput: false))
                    // action
                    accountLinkingManager.updateConnectionAndGrabOrders { (retailer, jsonString, ordersRemaining, viewController, error, sessionId) in
                        if error == .none {
                            if let jsonString = jsonString {
                                _userMessage.uploadPurchaseHistory(jsonString: jsonString) { (result) in
                                    switch result {
                                    case .success(let response):
                                        if !response.isEmpty {
                                            conversation.append(Message(text: response, isUserInput: false))
                                        }
                                    case .failure(let error):
                                        conversation.append(Message(text: "Failed to upload purchase history with error: \(error.localizedDescription)", isUserInput: false))
                                    }
                                }
                            } else {
                                conversation.append(Message(text: "Failed to grab new orders.", isUserInput: false))
                            }
                        } else {
                            conversation.append(Message(text: "Error encountered while grabbing orders.", isUserInput: false))
                            print(error)
                        }
                    }
                }) {
                    Text("Extract my data")
                        .foregroundColor(.black)
                        .frame(minWidth: 120)
                        .font(.system(size: 14))
                }
                .buttonStyle(BorderedButtonStyle())
                .border(Color.gray, width: 1.0)
            }
            
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(conversation.indices, id: \.self) { index in
                            let message = conversation[index].text
                            let isUserInput = conversation[index].isUserInput
                            VStack {
                                Text(message)
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)
                                        .background(isUserInput ? Color.black : Color.gray)
                                        //.cornerRadius(8)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        .font(.system(size: 14))
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
            .padding()
            
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    .frame(height: 80)
                    //.cornerRadius(8)
                    .onTapGesture {
                        isFocused = true
                    }
                
                TextEditor(text: $userInput)
                    .frame(height: 80)
                    .padding(.horizontal)
                    .foregroundColor(.black)
                    .font(.body)
                    .opacity(userInput.isEmpty ? 0.25 : 1)
                    .overlay(Text("Enter GPT prompt here")
                        .foregroundColor(.gray)
                        .opacity(userInput.isEmpty && !isFocused ? 1 : 0)
                        .alignmentGuide(.leading, computeValue: { d in d[.leading] })
                        .alignmentGuide(.top, computeValue: { d in d[.top] + 8 })
                    )
                    .focused($isFocused)
                    .onTapGesture {
                        isFocused = true
                    }
            }
            .padding()
            
            Button {
                if !userInput.isEmpty {
                    conversation.append(Message(text: userInput, isUserInput: true))

                    _userMessage.sendRequest(with: userInput) { result in
                        switch result {
                        case .success(let response):
                            let trimmedResponse = response.trimmingCharacters(in: .whitespacesAndNewlines) // Remove newline character from response
                            
                            // Check for "@SYSTEM@ getDealsJSON" in the response
                            if trimmedResponse.contains("@SYSTEM@ getDealsJSON") {
                                let messageWithoutSystemCommand = trimmedResponse.replacingOccurrences(of: "@SYSTEM@ getDealsJSON", with: "")
                                DispatchQueue.main.async {
                                    conversation.append(Message(text: messageWithoutSystemCommand, isUserInput: false))
                                }
                                
                                // Call getDeals API
                                _userMessage.getDeals { result in
                                    switch result {
                                    case .success(let dealsMessage):
                                        DispatchQueue.main.async {
                                            conversation.append(Message(text: dealsMessage, isUserInput: false))
                                        }
                                    case .failure(let error):
                                        print("Error getting deals: \(error.localizedDescription)")
                                    }
                                }
                            } else {
                                DispatchQueue.main.async {
                                    conversation.append(Message(text: trimmedResponse, isUserInput: false))
                                }
                            }
                        case .failure(let error):
                            conversation.append(Message(text: error.localizedDescription, isUserInput: false))
                        }
                    }

                    userInput = ""
                }
            }
            label: {
                Image(systemName: "paperplane.fill")
            }
            .disabled(userInput.isEmpty)
            /*
            HStack {
                Button(action: {
                    // Action for checking retailer
                    print("Check Retailer button tapped")
                    let linkedRetailers = accountLinkingManager.getLinkedRetailers()
                    let message = linkedRetailers.map { "\($0)" }.joined(separator: ", ")
                    conversation.append(Message(text: message, isUserInput: false))
                }) {
                    Text("Check Retailer")
                }
                
                Spacer()
                
                Button(action: {
                    // Action for getting orders
                    print("Get Orders button tapped")
                    accountLinkingManager.updateConnectionAndGrabOrders { (retailer, jsonString, ordersRemaining, viewController, error, sessionId) in
                        if error == .none {
                            if let jsonString = jsonString {
                                _userMessage.uploadPurchaseHistory(jsonString: jsonString) { (result) in
                                    switch result {
                                    case .success(let response):
                                        if !response.isEmpty {
                                            conversation.append(Message(text: response, isUserInput: false))
                                        }
                                    case .failure(let error):
                                        conversation.append(Message(text: "Failed to upload purchase history with error: \(error.localizedDescription)", isUserInput: false))
                                    }
                                }
                            } else {
                                conversation.append(Message(text: "Failed to grab new orders.", isUserInput: false))
                            }
                        } else {
                            conversation.append(Message(text: "Error encountered while grabbing orders.", isUserInput: false))
                            print(error)
                        }
                    }
                }) {
                    Text("Get Orders")
                }
            }
            .padding(.horizontal)
             */
        }
        .onAppear {
            
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
            _userMessage.initializeAgent { result in
                switch result {
                case .success(let message):
                    DispatchQueue.main.async {
                        conversation.append(Message(text: message, isUserInput: false))
                    }
                case .failure(let error):
                    print("Error initializing agent: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
