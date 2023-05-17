//
//  ConversationView.swift
//  Doops
//
//  Created by Andrew Yakovlev on 5/16/23.
//

import SwiftUI

struct ConversationView: View {
    @Binding var conversation: [Message]

    var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(conversation.indices, id: \.self) { index in
                        MessageView(message: conversation[index])
                    }
                }
                .padding()
                .frame(maxHeight: .infinity)
                .onChange(of: conversation) { _ in
                    let bottom = conversation.indices.last ?? 0
                    scrollViewProxy.scrollTo(bottom, anchor: .bottom)
                }
            }
        }
    }
}
