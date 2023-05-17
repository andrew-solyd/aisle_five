//
//  CustomTextEditorView.swift
//  Doops
//
//  Created by Andrew Yakovlev on 5/16/23.
//

import SwiftUI

struct CustomTextEditorView: View {
    @Binding var userInput: String
    @FocusState private var isFocused: Bool

    var body: some View {
        TextEditor(text: $userInput)
            .font(.system(size: 16))
            .foregroundColor(.textColor)
            .frame(height: 80)
            .padding(.horizontal)
            .overlay(
                Text(userInput.isEmpty && !isFocused ? "Enter GPT prompt here" : "")
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            )
            .focused($isFocused)
            .onTapGesture {
                isFocused = true
            }
    }
}
