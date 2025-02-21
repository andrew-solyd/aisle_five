//
//  MessageView.swift
//  Doops
//
//  Created by Andrew Yakovlev on 5/16/23.
//

import SwiftUI

struct HighlightedText: View {
    @EnvironmentObject var shoppingList: ShoppingList

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
            let highlightedAttributedString = createClickableAttributedString(highlighted)
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
    
    func createClickableAttributedString(_ text: Substring) -> AttributedString {
        
        var attributes: [NSAttributedString.Key: Any] = [:]
            
        // Set background color
        let itemName = String(text)
        let isInShoppingList = shoppingList.products.values.flatMap { $0 }.contains(where: { $0.name == itemName })
        let highlightColor = isInShoppingList ?
            Color(.sRGB, red: 177/255, green: 255/255, blue: 159/255, opacity: 0.5) : // Light green for items in the shopping list
            Color(.sRGB, red: 250/255, green: 255/255, blue: 159/255, opacity: 0.5)    // Light yellow for items not in the shopping list
        attributes[.backgroundColor] = UIColor(highlightColor)
        
        // Set font and font color
        let font = UIFont(name: "Parclo Serif Medium", size: 18)
        attributes[.font] = font
        attributes[.foregroundColor] = UIColor(Color.systemFontColor)
        
        // Create attributed string with attributes
        let attributedString = NSMutableAttributedString(string: String(text), attributes: attributes)
        
        // Make the highlighted part clickable
        let clickableRange = NSRange(location: 0, length: text.utf16.count)
        let encodedText = String(text).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let uniqueScheme = "myapp://\(encodedText)"
        
        attributedString.addAttribute(.link, value: uniqueScheme, range: clickableRange)
        
        return AttributedString(attributedString)
    }

}

struct MessageView: View {
    @EnvironmentObject var shoppingList: ShoppingList
    let message: Message
    
    @State private var lastAddedTime = Date(timeIntervalSince1970: 0)

    var body: some View {
        VStack {
            HighlightedText(message: message)
            .foregroundColor(message.isUserInput ? Color.userFontColor : Color.systemFontColor)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(
                message.isUserInput ? nil : RoundedRectangle(cornerRadius: 10)
                    .fill(Color.bodyColor)
                    .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 2, y: 2)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(red: 217/255, green: 225/255, blue: 233/255), lineWidth: 0.5))
            )
            .fixedSize(horizontal: false, vertical: true)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .font(Font.custom("Parclo Serif Regular", size: 18))
            .lineSpacing(_:5)
            .kerning(0.5)
            .onOpenURL { url in
                if let urlString = url.absoluteString.removingPercentEncoding,
                   urlString.hasPrefix("myapp://") {
                    let text = String(urlString.dropFirst(8))
                    toggleInShoppingList(text)
                }
            }
        }
    }

    func toggleInShoppingList(_ text: String) {
        let itemName = text.replacingOccurrences(of: "+", with: " ")
        // Searching for the product in all categories
        for (category, products) in shoppingList.products {
            if let existingIndex = products.firstIndex(where: { $0.name == itemName }) {
                shoppingList.products[category]?.remove(at: existingIndex)
                return
            }
        }
        // If product wasn't found, let's add it as To Sort
        let newProduct = Product(name: itemName, category: "To Sort")
        shoppingList.products["To Sort", default: []].append(newProduct)
    }
}
