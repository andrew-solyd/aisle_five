//
//  MessageView.swift
//  Doops
//
//  Created by Andrew Yakovlev on 5/16/23.
//

import SwiftUI

struct HighlightedText: View {
    let message: Message

    var body: some View {
        let attributedString = self.getAttributedString(text: self.message.text)
        Text(attributedString)
    }

    func getAttributedString(text: String) -> AttributedString {
        let bracketRegex = try! NSRegularExpression(pattern: "\\[(.*?)\\]", options: [])
        let matches = bracketRegex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))

        var lastEndLocation: Int = 0
        var attributedString = AttributedString()

        for match in matches {
            let nsRange = match.range(at: 1)
            
            // Convert NSRange to Range<String.Index>
            guard let range = Range(nsRange, in: text) else { continue }

            // Add non-highlighted part
            if range.lowerBound > text.index(text.startIndex, offsetBy: lastEndLocation) {
                var nonHighlighted = text[text.index(text.startIndex, offsetBy: lastEndLocation)..<range.lowerBound]
                if nonHighlighted.last == "[" {
                    nonHighlighted = nonHighlighted.dropLast()
                }
                attributedString.append(AttributedString(nonHighlighted))
            }
            
            // Add highlighted part
            let highlighted = text[range]
            var highlightedAttributedString = AttributedString(String(highlighted))
            highlightedAttributedString.backgroundColor = UIColor(Color.pink.opacity(0.2))
            attributedString.append(highlightedAttributedString)
            
            lastEndLocation = text.distance(from: text.startIndex, to: range.upperBound) + 1
        }

        // Add the remaining non-highlighted part
        if lastEndLocation < text.utf16.count {
            let nonHighlighted = text[text.index(text.startIndex, offsetBy: lastEndLocation)...]
            attributedString.append(AttributedString(String(nonHighlighted)))
        }

        return attributedString
    }
}

struct MessageView: View {
    let message: Message

    var body: some View {
        VStack {
            HighlightedText(message: message)
                .foregroundColor(.textColor)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(message.isUserInput ? Color.userColor : Color.aiColor)
                .fixedSize(horizontal: false, vertical: true)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 16))
                .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 2, y: 2)
        }
    }
}
