//
//  ActionButtonView.swift
//  Doops
//
//  Created by Andrew Yakovlev on 5/16/23.
//

import SwiftUI

struct ActionButtonView: View {
    @Binding var conversation: [Message]
    let _userMessage: userMessage

    var body: some View {
        HStack {
            
            Button(action: {
                conversation.append(Message(text: "Extracting and syncing your purchase data...", isUserInput: false))
                _userMessage.uploadPurchaseHistoryDemo() { (result) in
                    switch result {
                    case .success(let response):
                        if !response.isEmpty {
                            conversation.append(Message(text: response, isUserInput: false))
                        }
                    case .failure(let error):
                        conversation.append(Message(text: "Failed to upload purchase history with error: \(error.localizedDescription)", isUserInput: false))
                    }
                }
                
            }) {
                Text("Sync my data")
                    .foregroundColor(.black)
                    .frame(minWidth: 120)
                    .font(.system(size: 12))
            }
            .buttonStyle(BorderedButtonStyle())
            .border(Color.gray, width: 0.2)
            
            Spacer()
            
            NavigationLink(destination: ShoppingListView()) {
                Text("Shopping list")
                    .foregroundColor(.black)
                    .frame(minWidth: 120)
                    .font(.system(size: 12))
            }
            .buttonStyle(BorderedButtonStyle())
            .border(Color.gray, width: 0.2)
        }
    }
}
