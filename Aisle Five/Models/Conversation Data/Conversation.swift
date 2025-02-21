//
//  Conversation.swift
//  Doops
//
//  Created by Andrew Yakovlev on 6/20/23.
//

import Foundation

class ConversationHistory: ObservableObject {
    static let shared = ConversationHistory()
    
    @Published var messages: [[String: String]]
    
    init(messages: [[String: String]] = []) {
        self.messages = messages
    }
    
    func reset() {
        messages.removeAll()
    }
}
