//
//  AppInitializer.swift
//  Doops
//
//  Created by Andrew Yakovlev on 5/25/23.
//

import Foundation

class AppInitializer {
    
    private var _userMessage = userMessage()
    private var semaphore = DispatchSemaphore(value: 1)
    
    var conversation: [Message] = []
    var isWaitingForResponse: Bool = false
    var dotCount: Int = 0
    var waitingMessageIndex: Int? = nil
    
    func initialize(completion: @escaping (_ success: Bool) -> Void) {
        _userMessage.resetAgent { [weak self] result in
            switch result {
            case .success(let message):
                DispatchQueue.main.async {
                    print(message)
                }
            case .failure(let error):
                print("Error resetting agent: \(error.localizedDescription)")
            }
            
            self?.isWaitingForResponse = true
            self?.dotCount = 0
            self?.waitingMessageIndex = self?.conversation.endIndex
            self?.conversation.append(Message(text: "", isUserInput: false))
            
            self?._userMessage.initializeAgent { result in
                DispatchQueue.main.async {
                    if let index = self?.waitingMessageIndex {
                        self?.conversation.remove(at: index)
                        self?.waitingMessageIndex = nil
                    }
                    switch result {
                    case .success(let message):
                        DispatchQueue.main.async {
                            self?.conversation.append(Message(text: message, isUserInput: false))
                        }
                    case .failure(let error):
                        print("Error initializing agent: \(error.localizedDescription)")
                    }
                    
                    self?.isWaitingForResponse = false
                    completion(true)
                }
            }
        }
    }
}

