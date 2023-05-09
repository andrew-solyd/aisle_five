//
//  DoopsApp.swift
//  Doops
//
//  Created by Andrew Yakovlev on 5/1/23.
//

import SwiftUI
import BlinkReceiptStatic

@main
struct DoopsApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        
        // Add any other BlinkReceipt code here
        BRScanManager.shared().licenseKey = "sRwAAAEUU29seWRhcmlhLlNob3BHUFRBcHAP4yGd4kY35EhG6BE7wcfpoGOSHLYNP1zrP497z3JfIBvR019T3rF3S1ZjGGWx4JOVNCAJ/q66gQSzVsUG6C7dsbMIYpdciN3XPJ/72y5gcbLIgR0UsbfJ1VX72pZ8OZz5Kc4Zew9UATwKPvcgKXzdsWyxjS+hbpjRRj0TmgIQ1r3DxHCBUw=="
        
        BRScanManager.shared().prodIntelKey = "b6MW+LmixBlEYI+FaLaBJHl+9KZUGWNpKPtiMA97UVs="
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
