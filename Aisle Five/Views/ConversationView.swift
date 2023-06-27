//
//  ConversationView.swift
//  Doops
//
//  Created by Andrew Yakovlev on 5/16/23.
//

import SwiftUI

struct ConversationView: View {
    
    @EnvironmentObject var shoppingList: ShoppingList
    @EnvironmentObject var userSession: UserSession

    @Binding var conversation: [Message]
    @Binding var isWaitingForResponse: Bool
    @Binding var dotCount: Int
    @Binding var waitingMessageIndex: Int?
    @Binding var isTextEditorVisible: Bool
    @Binding var userInput: String
    @Binding var isShowingShoppingList: Bool
    @State private var scrollOffset: CGFloat = 0
    @State private var lastKeyboardVisibilityChangeDate = Date(timeIntervalSince1970: 0)
    @State private var contentHeight: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { geometry in
                ScrollViewReader { scrollView in
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(conversation.indices, id: \.self) { index in
                                MessageView(message: conversation[index])
                                    .environmentObject(ShoppingList.shared)
                            }
                            UserInputView(userInput: $userInput,
                                          isWaitingForResponse: $isWaitingForResponse,
                                          dotCount: $dotCount,
                                          conversation: $conversation,
                                          waitingMessageIndex: $waitingMessageIndex,
                                          isTextEditorVisible: $isTextEditorVisible)
                            Spacer()
                        }
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .onAppear {
                                        scrollOffset = -geometry.frame(in: .named("scrollView")).origin.y
                                        contentHeight = geometry.size.height
                                    }
                                    .onChange(of: geometry.size.height) { newHeight in
                                        contentHeight = newHeight
                                    }
                                    .preference(key: ViewOffsetKey.self, value: -geometry.frame(in: .named("scrollView")).origin.y)
                            }
                        )
                        .padding()
                        .frame(maxHeight: .infinity)
                        .onPreferenceChange(ViewOffsetKey.self) { offset in
                            let delta = offset - scrollOffset
                            scrollOffset = offset
                            
                            // print("delta: \(delta)")
                            // print("ratio: \(scrollOffset / geometry.frame(in: .named("scrollView")).height)")
                            // print("contentHeight: \(contentHeight)")
                            
                            let keyboardVisibilityChangeDelay: TimeInterval = 0.75
                            
                            if Date().timeIntervalSince(lastKeyboardVisibilityChangeDate) > keyboardVisibilityChangeDelay && !isWaitingForResponse {
                                if delta < -5 {
                                    // Swipe Down / Scroll Up to hide the keyboard
                                    DispatchQueue.main.async {
                                        isTextEditorVisible = false
                                        lastKeyboardVisibilityChangeDate = Date()
                                    }
                                } else if delta > 10 && ( scrollOffset / geometry.frame(in: .named("scrollView")).height ) > 0.55 {
                                    // User has reached the bottom of the ScrollView, show the keyboard
                                    DispatchQueue.main.async {
                                        isTextEditorVisible = true
                                        lastKeyboardVisibilityChangeDate = Date()
                                    }
                                } else if delta > 10  &&  contentHeight < ( geometry.frame(in: .named("scrollView")).height - 50 ) {
                                    // User has reached the bottom of the ScrollView, show the keyboard
                                    DispatchQueue.main.async {
                                        isTextEditorVisible = true
                                        lastKeyboardVisibilityChangeDate = Date()
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, isTextEditorVisible ? 100 : 0)
                    .keyboardAdaptive()
                    .coordinateSpace(name: "scrollView")
                    .onChange(of: isWaitingForResponse) { newValue in
                        // If we're waiting for a response, hide the keyboard
                        if newValue {
                            isTextEditorVisible = false
                        } else {
                            isTextEditorVisible = true
                        }
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
            // Shopping List Button
            Button(action: {
                isShowingShoppingList = true
            }) {
                Image("list-icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48) // Frame set to 48x48
                    .background(Color.clear) // Clear background
                    .opacity(0.5)
            }
            .padding(.bottom, 30)
            .padding(.trailing, 30)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            ZStack {
                // Disclaimer Text
                if isTextEditorVisible && !userSession.isDisclaimerDismissed {
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
                    .padding(.bottom, 38)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading) // set alignment to .bottomLeading for bottom left alignment
                }
            }
        }
        .onAppear() {
            print("Conversation View")
            print(isWaitingForResponse)
        }
    }
}

struct ViewOffsetKey: PreferenceKey {
  typealias Value = CGFloat
  static var defaultValue = CGFloat.zero
  static func reduce(value: inout Value, nextValue: () -> Value) {
    value += nextValue()
  }
}
