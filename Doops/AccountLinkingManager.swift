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
    
    init() {
        manager = BRAccountLinkingManager.shared()
        connection = BRAccountLinkingConnection(retailer: BRAccountLinkingRetailer.wegmans, username: "yakovlev.andrei@gmail.com", password: "RD8hj5OFNYN^$=E")
        // connection = BRAccountLinkingConnection(retailer: BRAccountLinkingRetailer.target, username: "wafts.roaster-0v@icloud.com", password: "migVu9-nofbic-saxkor")
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
        
        manager.resetHistory(for: .wegmans)
        
        // func grabNewOrders(for retailer: BRAccountLinkingRetailer, withCompletion completion: @escaping (BRAccountLinkingRetailer, BRScanResults?, Int, UIViewController?, BRAccountLinkingError, String) -> Void) -> BRAccountLinkingConnectionIdentifier?
        
        manager.grabNewOrders(for: .wegmans) { retailer, results, ordersRemaining, viewController, error, sessionId in
            if error == .none {
                let receiptDateValue = results?.receiptDate
                let receiptDateString = receiptDateValue?.value ?? "unknown"
                
                print("Receipt date: \(receiptDateString)")
                
                completion(retailer, results, ordersRemaining, viewController, error, sessionId)
            } else {
                completion(retailer, nil, ordersRemaining, viewController, error, sessionId)
            }
        }
    }
    
    func updateConnectionAndGrabOrders(completion: @escaping (BRAccountLinkingRetailer, String?, Int, UIViewController?, BRAccountLinkingError, String) -> Void) {
        // Update connection with the latest configuration
        manager.update(connection)
        
        // Create a configuration object with your desired settings
        let config = BRAccountLinkingConfiguration()
        config.dayCutoff = 10
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
                completion(retailer, jsonString, ordersRemaining, viewController, error, sessionId)
            } else {
                completion(retailer, nil, ordersRemaining, viewController, error, sessionId)
            }
        }
    }
        
    func convertScanResultsToJSON(results: BRScanResults) -> String {
        var productsList: [[String: Any]] = []
        
        for product in results.products {
            var productDict: [String: Any] = [:]
            
            // Add all product properties to the dictionary
            if let productNumber = product.productNumber?.value {
                productDict["productNumber"] = productNumber
            }
            
            if let productDescription = product.productDescription?.value {
                productDict["productDescription"] = productDescription
            }
            
            if let quantity = product.quantity?.value {
                let quantityFormatter = NumberFormatter()
                quantityFormatter.numberStyle = .decimal
                quantityFormatter.maximumFractionDigits = 2
                let quantityString = quantityFormatter.string(from: NSNumber(value: quantity))
                productDict["quantity"] = quantityString
            }

            if let unitPrice = product.unitPrice?.value {
                let unitPriceFormatter = NumberFormatter()
                unitPriceFormatter.numberStyle = .decimal
                unitPriceFormatter.maximumFractionDigits = 2
                let unitPriceString = unitPriceFormatter.string(from: NSNumber(value: unitPrice))
                productDict["unitPrice"] = unitPriceString
            }

            if let unitOfMeasure = product.unitOfMeasure?.value {
                productDict["unitOfMeasure"] = unitOfMeasure
            }

            if let totalPrice = product.totalPrice?.value {
                let totalPriceFormatter = NumberFormatter()
                totalPriceFormatter.numberStyle = .decimal
                totalPriceFormatter.maximumFractionDigits = 2
                let totalPriceString = totalPriceFormatter.string(from: NSNumber(value: totalPrice))
                productDict["totalPrice"] = totalPriceString
            }

            if let fullPrice = product.fullPrice?.value {
                let fullPriceFormatter = NumberFormatter()
                fullPriceFormatter.numberStyle = .decimal
                fullPriceFormatter.maximumFractionDigits = 2
                let fullPriceString = fullPriceFormatter.string(from: NSNumber(value: fullPrice))
                productDict["fullPrice"] = fullPriceString
            }

            if let priceAfterCoupons = product.priceAfterCoupons?.value {
                let priceAfterCouponsFormatter = NumberFormatter()
                priceAfterCouponsFormatter.numberStyle = .decimal
                priceAfterCouponsFormatter.maximumFractionDigits = 2
                let priceAfterCouponsString = priceAfterCouponsFormatter.string(from: NSNumber(value: priceAfterCoupons))
                productDict["priceAfterCoupons"] = priceAfterCouponsString
            }
            
            if let additionalLines = product.additionalLines {
                productDict["additionalLines"] = additionalLines
            }
            
            if let productUrl = product.productUrl {
                productDict["productUrl"] = productUrl
            }
            
            // Uncomment the following lines and implement the proper conversion if needed
            /*
            if let productName = product.productName {
                productDict["productName"] = productName
            }
            if let category = product.category {
                productDict["category"] = category
            }
            if let sector = product.sector {
                productDict["sector"] = sector
            }
            if let department = product.department {
                productDict["department"] = department
            }
            if let majorCategory = product.majorCategory {
                productDict["majorCategory"] = majorCategory
            }
            if let subCategory = product.subCategory {
                productDict["subCategory"] = subCategory
            }
            if let size = product.size {
                productDict["size"] = size
            }
            */
            
            productsList.append(productDict)
        }
        
        let jsonData = try! JSONSerialization.data(withJSONObject: productsList, options: .prettyPrinted)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        
        return jsonString
    }
}

