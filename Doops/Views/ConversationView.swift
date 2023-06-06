//
//  ConversationView.swift
//  Doops
//
//  Created by Andrew Yakovlev on 5/16/23.
//

import SwiftUI

struct ConversationView: View {
    @Binding var conversation: [Message]
    @Binding var isWaitingForResponse: Bool
    @Binding var dotCount: Int
    @Binding var waitingMessageIndex: Int?
    @Binding var isTextEditorVisible: Bool
    @Binding var userInput: String
    let _userMessage: userMessage

    var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(conversation.indices, id: \.self) { index in
                        MessageView(message: conversation[index])
                    }
                    CustomTextEditorView(userInput: $userInput,
                                         isWaitingForResponse: $isWaitingForResponse,
                                         dotCount: $dotCount,
                                         conversation: $conversation,
                                         waitingMessageIndex: $waitingMessageIndex,
                                         isTextEditorVisible: $isTextEditorVisible,
                                         _userMessage: _userMessage)
                }
                .padding()
                .frame(maxHeight: .infinity)
            }
            .onAppear {
                scrollToBottom(scrollViewProxy: scrollViewProxy)
            }
        }
    }

    private func scrollToBottom(scrollViewProxy: ScrollViewProxy) {
        withAnimation {
            scrollViewProxy.scrollTo(conversation.indices.last, anchor: .bottom)
        }
    }
}

