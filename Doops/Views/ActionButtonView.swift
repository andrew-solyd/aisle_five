//
//  ActionButtonView.swift
//  Doops
//
//  Created by Andrew Yakovlev on 5/16/23.
//

import SwiftUI

struct ActionButtonView: View {
    @Binding var conversation: [Message]
    @Binding var isLinked: Bool
    @Binding var isButtonDisabled: Bool
    @Binding var isUploaded: Bool
    let accountLinkingManager: AccountLinkingManager
    let _userMessage: userMessage
    let semaphore: DispatchSemaphore

    var body: some View {
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
                conversation.append(Message(text: "Extracting and syncing your purchase data...", isUserInput: false))
                isUploaded = true
                
                _userMessage.uploadPurchaseHistoryDemo() { (result) in
                    switch result {
                    case .success(let response):
                        if !response.isEmpty {
                            conversation.append(Message(text: response, isUserInput: false))
                            isUploaded = true
                        }
                    case .failure(let error):
                        conversation.append(Message(text: "Failed to upload purchase history with error: \(error.localizedDescription)", isUserInput: false))
                    }
                }
                
                /*
                accountLinkingManager.updateConnectionAndGrabOrders { (retailer, jsonString, ordersRemaining, viewController, error, sessionId) in
                    
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
                                semaphore.signal()
                            }
                        } else {
                            print("nil order data, skipping")
                            semaphore.signal()
                        }
                    } else {
                        print("ERRRRRORRRRR!")
                        print(error)
                        print(error.hashValue)
                        isUploaded = false
                        semaphore.signal()
                    }
                 
                }
                */
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
    }
}
