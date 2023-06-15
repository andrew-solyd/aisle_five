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
    @Binding var isShowingShoppingList: Bool
    let _userMessage: userMessage
    @State private var scrollOffset: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isAtBottom: Bool = true
    @State var wholeSize: CGSize = .zero
    @State var scrollViewSize: CGSize = .zero
    
    var body: some View {
        ZStack(alignment: .top) {
            ChildSizeReader(size: $wholeSize) {
                ScrollView {
                    ChildSizeReader(size: $scrollViewSize) {
                        VStack(spacing: 8) {
                            ForEach(conversation.indices, id: \.self) { index in
                                MessageView(message: conversation[index])
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
                                // .preference(key: ViewOffsetKey.self, value: -geometry.frame(in: .named("scrollView")).minY)
                                    .preference(
                                        key: ViewOffsetKey.self,
                                        value: -1 * geometry.frame(in: .named("scrollView")).origin.y
                                    )
                            }
                        )
                        .onPreferenceChange(ViewOffsetKey.self) { offset in
                            // Store the previous offset
                            let previousOffset = scrollOffset
                            // Update the current scroll offset
                            scrollOffset = offset

                            print("scrollOffset: \(scrollOffset)")
                            print("previousOffset: \(previousOffset)")
                            print("scrollViewSize height: \(scrollViewSize.height)")
                            print("wholeSize height: \(wholeSize.height)")
                            
                            if scrollViewSize.height <= wholeSize.height {
                                print("in the pocket")
                                // Not enough content to scroll, so don't change the keyboard visibility
                                if scrollOffset < 0 {
                                    // Swipe Down / Scroll Up to hide the keyboard
                                    isTextEditorVisible = false
                                } else if scrollOffset > 0 {
                                    // User has reached the bottom of the ScrollView, show the keyboard
                                    isTextEditorVisible = true
                                }
                            } else {
                                print("not in the pocket")
                                if scrollOffset < previousOffset {
                                    // Swipe Down / Scroll Up to hide the keyboard
                                    isTextEditorVisible = false
                                } else if scrollOffset >= scrollViewSize.height - wholeSize.height {
                                    // User has reached the bottom of the ScrollView, show the keyboard
                                    isTextEditorVisible = true
                                }
                            }
                        }
                    }
                }
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

struct ChildSizeReader<Content: View>: View {
  @Binding var size: CGSize

  let content: () -> Content
  var body: some View {
    ZStack {
      content().background(
        GeometryReader { proxy in
          Color.clear.preference(
            key: SizePreferenceKey.self,
            value: proxy.size
          )
        }
      )
    }
    .onPreferenceChange(SizePreferenceKey.self) { preferences in
      self.size = preferences
    }
  }
}

struct SizePreferenceKey: PreferenceKey {
  typealias Value = CGSize
  static var defaultValue: Value = .zero

  static func reduce(value _: inout Value, nextValue: () -> Value) {
    _ = nextValue()
  }
}
