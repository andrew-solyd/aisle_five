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
            Image("solydaria-logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .padding(.bottom, 20)
            
            Text("Shopping List Co-Pilot")
                .font(Font.custom("Parclo Serif Black", size: 20))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bodyColor)
        .onAppear {
     
        }
    }
}
