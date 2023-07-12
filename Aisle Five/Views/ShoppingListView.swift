//
//  ShoppingListView.swift
//  Doops
//
//  Created by Andrew Yakovlev on 5/25/23.
//

import SwiftUI

struct ShoppingListView: View {
    @EnvironmentObject var shoppingList: ShoppingList

    @Binding var isShowingShoppingList: Bool
    @State private var isInEditMode = false
    @State private var isPixelVisible = false
    @State private var showConfirmationAlert = false
    
    var body: some View {
        VStack {
            ZStack {
                shoppingListContent
            }
            .overlay(
               VStack(spacing: 0) {
                   // Red bar at the top
                   Rectangle()
                       .frame(height: 40)
                       .foregroundColor(.bodyColor)
                   LinearGradient(gradient: Gradient(colors: [.bodyColor, .clear]), startPoint: .top, endPoint: .bottom)
                       .frame(height: 35)

                   Spacer()

                   // Blue bar at the bottom
                   LinearGradient(gradient: Gradient(colors: [.clear, .bodyColor]), startPoint: .top, endPoint: .bottom)
                       .frame(height: 35)
               }
            )
            .edgesIgnoringSafeArea(.all) // Allow the overlays to extend into the safe area
            buttonBar
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 1, height: 1)
                .opacity(isPixelVisible ? 1 : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bodyColor)
    }
    
    func customTextView(_ content: String, fontName: String, fontSize: CGFloat) -> some View {
        Text(content)
            .font(Font.custom(fontName, size: fontSize))
            .lineSpacing(5)
            .kerning(0.5)
            .padding(.horizontal, 30)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.systemFontColor)
    }
    
    var shoppingListContent: some View {
        ScrollView {
            if shoppingList.products.isEmpty {
            // Empty state view
                VStack(spacing: 20) {
                    Spacer()
                    customTextView("", fontName: "Parclo Serif Black", fontSize: 22)
                    Spacer()
                    customTextView("Your Shopping List is Empty", fontName: "Parclo Serif Black", fontSize: 22)
                    customTextView("Tap on highlighted items in your Co-Pilot chat to add them here.", fontName: "Parclo Serif Regular", fontSize: 18)
                    customTextView("Try these sample prompts for inspiration:", fontName: "Parclo Serif Medium", fontSize: 18)
                    customTextView("1. Let's make Japanese-style fish sticks\n2. Plan a week's worth of meals under $50\n3. I'm doing Whole30, can you suggest 3 meal ideas?", fontName: "Parclo Serif Regular", fontSize: 14)
                    customTextView("Fun tip: To give your Co-Pilot a celebrity personality, just ask!", fontName: "Parclo Serif Regular", fontSize: 14)
                    Spacer()
                }
                
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Spacer()
                    customTextView("", fontName: "Parclo Serif Black", fontSize: 48)
                    Spacer()
                    ForEach(shoppingList.products.keys.sorted(), id: \.self) { category in
                        productCategorySection(category)
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            // Check if there's an ongoing sorting operation
            guard !SmartListAPI.isSortingInProgress else {
                return
            }
            // Check if there are items in the "To Sort" category
            guard let toSortItems = shoppingList.products["To Sort"], !toSortItems.isEmpty else {
                return
            }            
            // Start sorting operation
            SmartListAPI.sortItems()
        }
    }
    
    func productCategorySection(_ category: String) -> some View {
        let sortedProducts = (shoppingList.products[category] ?? []).sorted {
            let productName1 = extractProductName(from: $0.name)
            let productName2 = extractProductName(from: $1.name)
            return productName1 < productName2
        }
        if !sortedProducts.isEmpty {
            return AnyView(
                Section(header: Text(category)
                            .font(Font.custom("Parclo Serif Black", size: 22))
                            .foregroundColor(Color.systemFontColor)
                            .padding(.vertical, 10)
                            .padding(.leading, 20)) {
                    
                    ForEach(sortedProducts, id: \.id) { product in
                        productButton(product)
                    }
                                
                    .padding(.horizontal, 15)
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    func productButton(_ product: Product) -> some View {
        Button(action: {
            shoppingList.toggleProductCheckStatus(product: product)
            isPixelVisible.toggle()
        }) {
            HStack {
                Image(systemName: product.isChecked ? "checkmark.square.fill" : "square")
                    .foregroundColor(Color.systemFontColor)
                
                Text(product.name)
                    .strikethrough(product.isChecked, color: .black)
                    .font(Font.custom("Parclo Serif Medium", size: 18))
                    .foregroundColor(Color.systemFontColor)
                
                Spacer()
                
                if isInEditMode {
                    removeProductButton(product)
                }
                
            }
            .frame(maxWidth: .infinity)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.bodyColor)
                .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 2, y: 2)
                .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(Color(red: 217/255, green: 225/255, blue: 233/255), lineWidth: 0.5))
        )
    }
    
    func extractProductName(from productString: String) -> String {
        let scanner = Scanner(string: productString)
        var scannedNumber: Int = 0

        if scanner.scanInt(&scannedNumber) {
            // Check if there is a number at the start of the string
            let indexFirstCapitalLetter = productString.firstIndex(where: { $0.isUppercase }) ?? productString.startIndex
            return String(productString[indexFirstCapitalLetter...])
        } else {
            // If there is no number at the start of the string, the whole string is the product name
            return productString
        }
    }
    
    func removeProductButton(_ product: Product) -> some View {
        Button(action: {
                removeProduct(product)
            }) {
                Image(systemName: "minus.circle")
                    .foregroundColor(.red)
                    .padding(.trailing, 10)
                    .frame(width: 15, height: 15)
            }
    }
    
    func removeProduct(_ product: Product) {
        for category in shoppingList.products.keys {
            if let index = shoppingList.products[category]?.firstIndex(where: { $0.id == product.id }) {
                shoppingList.products[category]?.remove(at: index)
                if shoppingList.products[category]?.isEmpty ?? false {
                    shoppingList.products.removeValue(forKey: category)
                }
            }
        }
    }
    
    func removeAllProducts() {
        showConfirmationAlert = false
        shoppingList.products.removeAll()
    }
    
    @ViewBuilder
    var buttonBar: some View {
        if isInEditMode {
            Button("Done") {
                isInEditMode.toggle()
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 30)
            .frame(maxWidth: .infinity)
        // if isInDropMode create confirmatoin or back dialogue in same space as isInEditMode above
        // if confirmation execute removeAllProducts()
        } else {
            HStack {
                ButtonView(action: {
                    isShowingShoppingList = false
                }, imageName: "back-icon")
                Spacer()
                /*
                ButtonView(action: {
                    // Manually add item to ShoppingList model
                }, imageName: "add-icon")
                */
                Spacer()
                Spacer()
                ButtonView(action: {
                    isInEditMode.toggle()
                }, imageName: "remove-icon")
                Spacer()
                ButtonView(action: {
                    // Delete shopping list button
                    showConfirmationAlert = true
                }, imageName: "delete-icon")
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 30)
            .frame(maxWidth: .infinity)
            .alert(isPresented: $showConfirmationAlert) {
                Alert(
                    title: Text("Delete Shopping List"),
                    message: Text("Are you sure you want to delete the shopping list? This action cannot be undone."),
                    primaryButton: .cancel(),
                    secondaryButton: .destructive(Text("Delete"), action: removeAllProducts)
                )
            }
        }
    }
}

struct ButtonView: View {
    let action: () -> Void
    let imageName: String

    var body: some View {
        Button(action: action) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 48)
                .background(Color.clear)
                .opacity(0.5)
        }
    }
}
