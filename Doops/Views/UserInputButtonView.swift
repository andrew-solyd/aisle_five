//
//  UserInputButtonView.swift
//  Doops
//
//  Created by Andrew Yakovlev on 5/16/23.
//

import SwiftUI

struct UserInputButtonView: View {
    @Binding var userInput: String
    @Binding var isWaitingForResponse: Bool
    @Binding var dotCount: Int
    @Binding var conversation: [Message]
    @Binding var waitingMessageIndex: Int?
    let _userMessage: userMessage
    
    var body: some View {
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
                        processResponse(response)
                    case .failure(let error):
                        DispatchQueue.main.async {
                            removeWaitingMessage()
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
        .accentColor(userInput.isEmpty ? .gray : .systemFontColor)
        Spacer(minLength: 10)
    }
    
    func processResponse(_ response: String) {
        DispatchQueue.main.async {
            removeWaitingMessage()
            let trimmedResponse = response.trimmingCharacters(in: .whitespacesAndNewlines)
            if let range = trimmedResponse.range(of: "#getDeals") {
                let messageWithoutSystemCommand = String(trimmedResponse[..<range.lowerBound])
                DispatchQueue.main.async {
                    conversation.append(Message(text: messageWithoutSystemCommand, isUserInput: false))
                }
                getDeals()
            } else {
                DispatchQueue.main.async {
                    conversation.append(Message(text: trimmedResponse, isUserInput: false))
                }
                isWaitingForResponse = false
            }
        }
    }
    
    func removeWaitingMessage() {
        if let index = self.waitingMessageIndex {
            conversation.remove(at: index)
            self.waitingMessageIndex = nil
        }
    }
    
    func getDeals() {
        isWaitingForResponse = true
        dotCount = 0
        waitingMessageIndex = conversation.endIndex
        conversation.append(Message(text: "", isUserInput: false))
        _userMessage.getDeals { result in
            DispatchQueue.main.async {
                removeWaitingMessage()
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
    }
}
