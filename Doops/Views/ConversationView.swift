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
    @State private var scrollOffset: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isAtBottom: Bool = true
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(conversation.indices, id: \.self) { index in
                            MessageView(message: conversation[index])
                                .onAppear {
                                    lastSeenMessageIndex = index
                                }
                        }
                        UserInputView(userInput: $userInput,
                                      isWaitingForResponse: $isWaitingForResponse,
                                      dotCount: $dotCount,
                                      conversation: $conversation,
                                      waitingMessageIndex: $waitingMessageIndex,
                                      isTextEditorVisible: $isTextEditorVisible,
                                      _userMessage: _userMessage)
                        Spacer()
                    }
                    .padding()
                    .frame(maxHeight: .infinity)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .preference(key: ViewOffsetKey.self, value: -geometry.frame(in: .named("scrollView")).minY)
                        }
                    )
                }
                .keyboardAdaptive()
                .coordinateSpace(name: "scrollView")
                .onPreferenceChange(ViewOffsetKey.self) { offset in
                    let previousOffset = scrollOffset
                    scrollOffset = offset

                    if scrollOffset <= 0 { return }

                    if scrollOffset > previousOffset {
                        isAtBottom = true
                    } else if scrollOffset < previousOffset {
                        isAtBottom = false
                    }

                    print("Scroll offset: \(scrollOffset), isAtBottom: \(isAtBottom)")

                    // Scroll up
                    if isAtBottom {
                        isTextEditorVisible = true
                    }
                    // Scroll down
                    if !isAtBottom {
                        isTextEditorVisible = false
                    }
                }


            }
            // System icons mask bar
            Color.bodyColor
                .frame(height: 50)
                .ignoresSafeArea(edges: .top)
                .alignmentGuide(.top, computeValue: { _ in 0 })

            // This needs to hit 0 opacity by the time we scroll into the mask bar
            LinearGradient(gradient: Gradient(colors: [Color.white.opacity(1.0), Color.white.opacity(0.0)]),
                           startPoint: .top,
                           endPoint: .bottom)
                .frame(height: 100) // Adjust the height to control the fade-out length
                .ignoresSafeArea(edges: .top)
                .alignmentGuide(.top, computeValue: { _ in 0 })
            // A bit of margin for the text editor

        }
    }
}

struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

