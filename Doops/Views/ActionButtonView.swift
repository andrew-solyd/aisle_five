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
