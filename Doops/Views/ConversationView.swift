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

