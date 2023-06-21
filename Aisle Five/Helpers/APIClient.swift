//
//  APIClient.swift
//  Doops
//
//  Created by Andrew Yakovlev on 5/1/23.
//

import Foundation

enum APIError: Error {
    case requestFailed
    case invalidResponse
}

struct SmartListAPI {
    
    static var isSortingInProgress = false
    
    #if DEBUG
    static let baseURL = URL(string: "http://localhost:8080")!
    #else
    static let baseURL = URL(string: "https://solyd-open-api.fly.dev")!
    #endif
    
    // Function to send Shopping List to API as a POST call
    static func sortItems() {
        isSortingInProgress = true
        if let jsonData = shoppingListToJSON(ShoppingList.shared) {
           // Print the JSON data as a string
            if String(data: jsonData, encoding: .utf8) != nil {
               let url = baseURL.appendingPathComponent("sort-items")
               var request = URLRequest(url: url)
               request.httpMethod = "POST"
               request.setValue("application/json", forHTTPHeaderField: "Content-Type")
               request.httpBody = jsonData
               
               let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                   if let error = error {
                       print("Error: \(error)")
                   }
                   
                   guard let data = data else {
                       print("Empty response data")
                       return
                   }
                   
                   do {
                       let sortedItems = try JSONDecoder().decode([SortedItem].self, from: data)
                       for item in sortedItems {
                           UpdateQueue.shared.addItem(item)
                       }
                       isSortingInProgress = false
                   } catch {
                       print("Error decoding sorted items: \(error)")
                       isSortingInProgress = false
                   }
               }
               task.resume()
           }
        }
    }
}

struct CopilotAPI {
    
    #if DEBUG
    static let baseURL = URL(string: "http://localhost:8080")!
    #else
    static let baseURL = URL(string: "https://solyd-open-api.fly.dev")!
    #endif
    
    func initialize(completion: @escaping (Result<CopilotInitialization, Error>) -> Void) {
        let url = CopilotAPI.baseURL.appendingPathComponent("initialize")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.requestFailed))
                return
            }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let systemInstructions = jsonResponse?["systemInstructions"] as? String,
                   let chatGPTresponse = jsonResponse?["chatGPTresponse"] as? String {
                    let initialization = CopilotInitialization(systemInstructions: systemInstructions, chatGPTresponse: chatGPTresponse)
                    completion(.success(initialization))
                } else {
                    completion(.failure(APIError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func complete(with conversationHistory: [[String: String]], completion: @escaping (Result<String, Error>) -> Void) {
        let url = CopilotAPI.baseURL.appendingPathComponent("user-message")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["messages": conversationHistory]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let message = json?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(.success(content))
                } else {
                    completion(.failure(APIError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
