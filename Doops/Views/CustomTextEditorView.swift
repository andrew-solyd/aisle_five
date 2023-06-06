//
//  CustomTextEditorView.swift
//  Doops
//
//  Created by Andrew Yakovlev on 5/16/23.
//

import SwiftUI

struct CustomTextEditorView: View {
    @Binding var userInput: String
    @Binding var isWaitingForResponse: Bool
    @Binding var dotCount: Int
    @Binding var conversation: [Message]
    @Binding var waitingMessageIndex: Int?
    @Binding var isTextEditorVisible: Bool
    let _userMessage: userMessage
    
    @FocusState private var isFocused: Bool
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            if isTextEditorVisible {
                TextField("", text: $userInput)
                    .font(Font.custom("Parclo Serif Regular", size: 17))
                    ._lineHeightMultiple(1.3)
                    .foregroundColor(.systemFontColor)
                    .frame(height: 90)
                    .focused($isFocused)
                    .submitLabel(.send)
                    .onSubmit {
                        sendMessage()
                    }
                    .background(Color.clear)
            }
        }
        .onChange(of: isTextEditorVisible) { newValue in
            if newValue {
                isFocused = true
            }
        }
        .onAppear {
            userInput = ""
            presentationMode.wrappedValue.dismiss()
        }
    }

    func sendMessage() {
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
        }
        userInput = "" // Clear the user input after sending
        isTextEditorVisible = false // Hide the text editor after sending
        // Dismiss the keyboard when tapped outside the text editor
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
        
    func processResponse(_ response: String) {
        DispatchQueue.main.async {
            removeWaitingMessage()
            let trimmedResponse = response.trimmingCharacters(in: .whitespacesAndNewlines)
            DispatchQueue.main.async {
                conversation.append(Message(text: trimmedResponse, isUserInput: false))
            }
            isWaitingForResponse = false
        }
    }

    func removeWaitingMessage() {
        if let index = self.waitingMessageIndex {
            conversation.remove(at: index)
            self.waitingMessageIndex = nil
        }
    }
}
