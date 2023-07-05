//
//  DisclaimerView.swift
//  Doops
//
//  Created by Andrew Yakovlev on 6/28/23.
//

import SwiftUI

struct DisclaimerView: View {
    @EnvironmentObject var userSession: UserSession
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) { // set alignment to .leading for left alignment
            Text("By messaging Aisle Five, you are agreeing to our")
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(spacing: 0) {
                Link("Terms of Service", destination: URL(string: "https://www.aislefive.us/legal")!)
                    .font(.caption)
                    .bold()
                    .foregroundColor(Color.systemFontColor)
                Text(" and ")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Link("Privacy Policy", destination: URL(string: "https://www.aislefive.us/legal")!)
                    .font(.caption)
                    .bold()
                    .foregroundColor(Color.systemFontColor)
                Text(". ")
                    .font(.caption)
                    .foregroundColor(.primary)
                Button(action: {
                    userSession.isDisclaimerDismissed = true
                }) {
                    Text("Dismiss")
                        .font(.caption)
                        .bold()
                        .foregroundColor(Color.systemFontColor)
                }
                Text(".")
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
        .padding(.leading, 20) // add a leading padding of 30px
        .padding(.bottom, 13)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading) // set alignment to .bottomLeading for bottom left alignment
    }
}

