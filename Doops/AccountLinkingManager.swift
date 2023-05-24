//
//  AccountLinkingManager.swift
//  Doops
//
//  Created by Andrew Yakovlev on 5/1/23.
//

import BlinkReceiptStatic
import BlinkEReceiptStatic

class AccountLinkingManager {
    let manager: BRAccountLinkingManager
    let connection: BRAccountLinkingConnection
    
    private var hasSuccessfullyGrabbedOrders = false
    
    init() {
        manager = BRAccountLinkingManager.shared()
        // connection = BRAccountLinkingConnection(retailer: BRAccountLinkingRetailer.wegmans, username: "yakovlev.andrei@gmail.com", password: "RD8hj5OFNYN^$=E")
        connection = BRAccountLinkingConnection(retailer: BRAccountLinkingRetailer.target, username: "rafagoldberg@gmail.com", password: "sihmud-sopgi3-beckYp")
    }
    
    // Links the user's account to the retailer specified in the connection object and calls the completion handler with a boolean indicating whether the account was successfully linked and a string message describing the outcome
    func linkToRetailer(completion: ((Bool, String) -> Void)? = nil) {
        manager.linkRetailer(with: connection)

        manager.verifyRetailer(with: connection, withCompletion: { error, viewController, message in
            if error == .none {
                completion?(true, "Successfully linked account!")
            } else {
                completion?(false, "Failed to link retailer...")
            }
        })
    }
    
    func getLinkedRetailers() -> [NSNumber] {
        let linkedRetailers = manager.getLinkedRetailers()
        return linkedRetailers
    }
    
    func getOrders(completion: @escaping (BRAccountLinkingRetailer, BRScanResults?, Int, UIViewController?, BRAccountLinkingError, String) -> Void) {
        print("Getting orders..")
        
        manager.resetHistory(for: .target)
        
        // func grabNewOrders(for retailer: BRAccountLinkingRetailer, withCompletion completion: @escaping (BRAccountLinkingRetailer, BRScanResults?, Int, UIViewController?, BRAccountLinkingError, String) -> Void) -> BRAccountLinkingConnectionIdentifier?
        
        manager.grabNewOrders(for: .target) { retailer, results, ordersRemaining, viewController, error, sessionId in
            if error == .none {
                let receiptDateValue = results?.receiptDate
                let receiptDateString = receiptDateValue?.value ?? "unknown"
                
                print("Receipt date: \(receiptDateString)")
                
                completion(retailer, results, ordersRemaining, viewController, error, sessionId)
            } else {
                print("ERROR!!")
                print(error)
                completion(retailer, nil, ordersRemaining, viewController, error, sessionId)
            }
        }
    }
    
    func updateConnectionAndGrabOrders(completion: @escaping (BRAccountLinkingRetailer, String?, Int, UIViewController?, BRAccountLinkingError, String) -> Void) {
        guard !hasSuccessfullyGrabbedOrders else {
            print("Orders have already been grabbed in this session.")
            return
        }
        // Update connection with the latest configuration
        manager.update(connection)
        
        // Create a configuration object with your desired settings
        let config = BRAccountLinkingConfiguration()
        config.dayCutoff = 16
        config.returnLatestOrdersOnly = false
        config.countryCode = "US"
        
        // Apply the configuration to the connection
        connection.configuration = config
        
        // Reset history and grab new orders for the specified retailer
        let retailer = connection.retailer
        manager.resetHistory(for: retailer)
        
        let _ = manager.grabNewOrders(for: retailer) { (retailer, results, ordersRemaining, viewController, error, sessionId) in
            if let results = results {
                let jsonString = self.convertScanResultsToJSON(results: results)
                // Determine the number of items in the JSON string
                if let data = jsonString.data(using: .utf8), let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    if jsonArray.count >= 20 {
                        // Only complete if there are 20 items or more
                        self.hasSuccessfullyGrabbedOrders = true
                        completion(retailer, jsonString, ordersRemaining, viewController, error, sessionId)
                    } else {
                        print("Less than 20 items, not completing.")
                        completion(retailer, nil, 0, viewController, .none, sessionId) // Feedback for not enough items
                    }
                } else {
                    print("ERROR!!")
                    print(error)
                    completion(retailer, jsonString, ordersRemaining, viewController, error, sessionId)
                }
            } else {
                print("ERROR!!")
                print(error)
                completion(retailer, nil, ordersRemaining, viewController, error, sessionId)
            }
        }
    }
        
    func convertScanResultsToJSON(results: BRScanResults) -> String {
        var productsList: [[String: Any]] = []
        
        for product in results.products {
            var productDict: [String: Any] = [:]
            
            if let productDescription = product.productDescription?.value {
                productDict["productDescription"] = productDescription
            }

            if let totalPrice = product.totalPrice?.value {
                let totalPriceFormatter = NumberFormatter()
                totalPriceFormatter.numberStyle = .decimal
                totalPriceFormatter.maximumFractionDigits = 2
                let totalPriceString = totalPriceFormatter.string(from: NSNumber(value: totalPrice))
                productDict["totalPrice"] = totalPriceString
            }
            
            productsList.append(productDict)
        }
        
        let jsonData = try! JSONSerialization.data(withJSONObject: productsList, options: .prettyPrinted)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        
        return jsonString
    }
}

