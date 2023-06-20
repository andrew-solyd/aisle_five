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

struct listCopilot {
    
    static var isSortingInProgress = false
    
    #if DEBUG
    static let baseURL = URL(string: "http://localhost:8080")!
    #else
    static let baseURL = URL(string: "https://solyd-open-api.fly.dev")!
    #endif
    
    // Function to send Shopping List to API as a POST call
    static func sortNewItems() {
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

struct userMessage {
    
    #if DEBUG
    static let baseURL = URL(string: "http://localhost:8080")!
    #else
    static let baseURL = URL(string: "https://solyd-open-api.fly.dev")!
    #endif
    
    func sendRequest(with message: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = userMessage.baseURL.appendingPathComponent("user-message")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters = ["message": message]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
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
    
    func resetAgent(completion: @escaping (Result<String, Error>) -> Void) {
        let url = userMessage.baseURL.appendingPathComponent("reset-agent")
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
                if let message = jsonResponse?["message"] as? String {
                    completion(.success(message))
                } else {
                    completion(.failure(APIError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func initializeAgent(completion: @escaping (Result<String, Error>) -> Void) {
        let url = userMessage.baseURL.appendingPathComponent("initialize-agent")
        
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
                if let message = jsonResponse?["message"] as? [String: String],
                   let initialMessage = message["content"] {
                    completion(.success(initialMessage))
                } else {
                    completion(.failure(APIError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
