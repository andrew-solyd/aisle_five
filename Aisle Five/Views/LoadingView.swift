//
//  LoadingView.swift
//  Doops
//
//  Created by Andrew Yakovlev on 5/25/23.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            Spacer() // Spacer added to center vertically
            Text("5")
                .font(Font.custom("Parclo Serif Black", size: 50))
            Spacer() // Spacer added to center vertically
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bodyColor)
        .onAppear {
            // Code to execute when the view appears
        }
    }
}
