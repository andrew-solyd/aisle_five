//
//  CopilotManager.swift
//  Doops
//
//  Created by Andrew Yakovlev on 6/20/23.
//

import Foundation

struct CopilotManager {
    
    let copilotAPI = CopilotAPI()
    var conversationHistory = ConversationHistory.shared
    
    func initialize(completion: @escaping (Result<String, Error>) -> Void) {
        copilotAPI.initialize { result in
            switch result {
            case .success(let initialization):
                let systemInstructionMessage = ["role": "system", "content": initialization.systemInstructions]
                let chatGPTresponseMessage = ["role": "assistant", "content": initialization.chatGPTresponse]
                DispatchQueue.main.async {
                    self.conversationHistory.messages.append(systemInstructionMessage)
                    self.conversationHistory.messages.append(chatGPTresponseMessage)
                    completion(.success(initialization.chatGPTresponse))
                }
            case .failure(let error):
                print("Error initializing agent: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    func complete(with message: String, completion: @escaping (Result<String, Error>) -> Void) {
        let userMessage = ["role": "user", "content": message]
        var updatedConversationHistory = conversationHistory.messages
        updatedConversationHistory.append(userMessage)

        copilotAPI.complete(with: updatedConversationHistory) { result in
            switch result {
            case .success(let assistantResponse):
                let assistantMessage = ["role": "assistant", "content": assistantResponse]
                DispatchQueue.main.async {
                    self.conversationHistory.messages.append(userMessage)
                    self.conversationHistory.messages.append(assistantMessage)
                }
                completion(.success(assistantResponse))
            case .failure(let error):
                print("Error completing chat: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
}
