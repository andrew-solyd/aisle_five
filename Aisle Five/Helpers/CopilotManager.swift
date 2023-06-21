//
//  CopilotManager.swift
//  Doops
//
//  Created by Andrew Yakovlev on 6/20/23.
//

import Foundation

struct CopilotManager {
    
    let copilot = shopCopilot()
    
    func initializeCopilot () {
        
        copilot.initializeAgent { result in
            
        }
        
    }
    
}
