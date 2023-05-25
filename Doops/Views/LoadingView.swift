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
            Image("solydaria-logo") // Make sure to add your image to the Assets.xcassets folder
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .padding(.bottom, 20) 
            
            Text("Shopping List Co-Pilot")
                .font(.title3)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bodyColor)
    }
}
