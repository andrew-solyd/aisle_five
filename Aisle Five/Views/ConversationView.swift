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
    
    let copilotManager: CopilotManager
        
    @State private var isWaitingForResponse:Bool = false
    @State private var dotCount: Int = 0
    @State private var waitingMessageIndex: Int? = nil
    @State private var isTextEditorVisible: Bool = false
    @State private var userInput: String = ""
    
    @Binding var isShowingShoppingList: Bool
    
    @State private var scrollOffset: CGFloat = 0
    @State private var lastKeyboardVisibilityChangeDate = Date(timeIntervalSince1970: 0)
    @State private var contentHeight: CGFloat = 0
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { geometry in
                ScrollViewReader { scrollView in
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(userSession.conversation.indices, id: \.self) { index in
                                MessageView(message: userSession.conversation[index])
                                    .environmentObject(ShoppingList.shared)
                                    .id(index)
                            }
                            UserInputView(userInput: $userInput,
                                          isWaitingForResponse: $isWaitingForResponse,
                                          dotCount: $dotCount,
                                          conversation: $userSession.conversation,
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
                        .onAppear {
                            if userSession.isInitialized && !isWaitingForResponse {
                                print("HELLO")
                                isTextEditorVisible = true
                            }
                        }
                        .onPreferenceChange(ViewOffsetKey.self) { offset in
                            let delta = offset - scrollOffset
                            scrollOffset = offset
                            
                            print("delta: \(delta)")
                            print("ratio: \(scrollOffset / geometry.frame(in: .named("scrollView")).height)")
                            print("contentHeight: \(contentHeight)")
                            
                            let keyboardVisibilityChangeDelay: TimeInterval = 0.75
                            
                            if Date().timeIntervalSince(lastKeyboardVisibilityChangeDate) > keyboardVisibilityChangeDelay && !isWaitingForResponse {
                                if delta < -20 {
                                    // Swipe Down / Scroll Up to hide the keyboard
                                    print("Swipe Down / Scroll Up to hide the keyboard")
                                    DispatchQueue.main.async {
                                        isTextEditorVisible = false
                                        lastKeyboardVisibilityChangeDate = Date()
                                    }
                                } else if delta > 10 && ( scrollOffset / geometry.frame(in: .named("scrollView")).height ) > 0.30 {
                                    // User has reached the bottom of the ScrollView, show the keyboard
                                    print("User has reached the bottom of the ScrollView, show the keyboard")
                                    DispatchQueue.main.async {
                                        isTextEditorVisible = true
                                        lastKeyboardVisibilityChangeDate = Date()
                                    }
                                } else if delta > 10  &&  contentHeight < ( geometry.frame(in: .named("scrollView")).height - 50 ) {
                                    // User has reached the bottom of the ScrollView, show the keyboard
                                    print("User has reached the bottom of the ScrollView, show the keyboard")
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
                    DisclaimerView()
                        .environmentObject(userSession)
                }
            }
        }
        .onAppear() {
            if !userSession.isInitialized {
                isWaitingForResponse = true
                dotCount = 0
                waitingMessageIndex = userSession.conversation.endIndex
                userSession.conversation.append(Message(text: "", isUserInput: false))
                copilotManager.initialize { result in
                    DispatchQueue.main.async {
                        if let index = self.waitingMessageIndex {
                            userSession.conversation.remove(at: index)
                            self.waitingMessageIndex = nil
                        }
                        switch result {
                        case .success(let message):
                            DispatchQueue.main.async {
                                userSession.conversation.append(Message(text: message, isUserInput: false))
                            }
                            userSession.isInitialized = true
                        case .failure(let error):
                            print("Error initializing agent: \(error.localizedDescription)")
                        }
                    }
                    isWaitingForResponse = false
                    isTextEditorVisible = true
                }
            }
        }
        .onReceive(timer) { _ in
            if isWaitingForResponse {
                // Check if the index is within the bounds of the array
                if let index = self.waitingMessageIndex, index < userSession.conversation.count {
                    let dots = String(repeating: ".", count: dotCount)
                    userSession.conversation[index] = Message(text: " \(dots)", isUserInput: false)
                    dotCount = (dotCount + 1) % 4
                }
            }
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
