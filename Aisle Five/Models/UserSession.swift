//
//  UserSession.swift
//  Doops
//
//  Created by Andrew Yakovlev on 6/22/23.
//

import Foundation

class UserSession: ObservableObject {
    @Published var isDisclaimerDismissed: Bool = false
    @Published var isInitialized: Bool = false
    @Published var conversation: [Message] = []
}
