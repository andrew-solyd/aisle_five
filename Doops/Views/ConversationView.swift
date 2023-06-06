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
    @State private var lastSeenMessageIndex: Int?
    @State private var scrollOffset: CGFloat = -1e10
    @State private var dragOffset: CGFloat = 0
    @State private var isAtBottom: Bool = true
    
    var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(conversation.indices, id: \.self) { index in
                        MessageView(message: conversation[index])
                        .onAppear {
                            lastSeenMessageIndex = index
                        }
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
                .background(GeometryReader {
                    Color.clear.preference(key: ViewOffsetKey.self,
                                           value: -$0.frame(in: .named("scrollView")).minY)
                })
            }
            .coordinateSpace(name: "scrollView")
            .onPreferenceChange(ViewOffsetKey.self) { offset in
                isAtBottom = offset > scrollOffset
                scrollOffset = offset
                print("Scroll offset: \(scrollOffset), isAtBottom: \(isAtBottom)")
                if scrollOffset > 0 && isAtBottom{
                    isTextEditorVisible = true
                }
                if scrollOffset < 0 && isTextEditorVisible{
                    isTextEditorVisible = false
                }
            }
            .gesture(
                DragGesture(minimumDistance: 50, coordinateSpace: .local)
                    .onChanged { value in
                        self.dragOffset = value.translation.height
                        print("Drag offset: \(dragOffset)")
                    }
                    .onEnded({ value in
                        // If swipe down
                        if value.translation.height > 0 {
                            // if TextEditor is visible hide it
                            if isTextEditorVisible {
                                isTextEditorVisible = false
                            }
                        }
                        // If swipe up
                        else if value.translation.height < 0 {
                            // if last message (most recent, most bottom one) has been reached make TextEditor visible
                            if !isTextEditorVisible && isAtBottom {
                                isTextEditorVisible = true
                            }
                        }
                    })
            )
        }
    }
}

struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

