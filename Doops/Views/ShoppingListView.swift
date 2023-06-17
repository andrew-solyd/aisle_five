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
    @State private var isInEditMode: Bool = false
    @State private var isPixelVisible = false
    
    var body: some View {
        VStack {
            ZStack {
                shoppingListContent
            }
            buttonBar
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 1, height: 1)
                .opacity(isPixelVisible ? 1 : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bodyColor)
    }
    
    var shoppingListContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(shoppingList.products.keys.sorted(), id: \.self) { category in
                    productCategorySection(category)
                }
            }
        }
    }
    
    func productCategorySection(_ category: String) -> some View {
        Section(header: Text(category)
                    .font(Font.custom("Parclo Serif Black", size: 22))
                    .foregroundColor(Color.systemFontColor)
                    .padding(.vertical, 10)
                    .padding(.leading, 20)) {
            ForEach(shoppingList.products[category] ?? [], id: \.id) { product in
                productButton(product)
            }
            .padding(.horizontal, 15)
        }
    }
    
    func productButton(_ product: Product) -> some View {
        Button(action: {
            product.isChecked.toggle()
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
        for category in shoppingList.products.keys {
            shoppingList.products[category]?.removeAll()
            if shoppingList.products[category]?.isEmpty ?? false {
                shoppingList.products.removeValue(forKey: category)
            }
        }
    }
    
    var buttonBar: some View {
        if isInEditMode {
            return AnyView(
                Button("Done") {
                    isInEditMode.toggle()
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 30)
                .frame(maxWidth: .infinity)
            )
        } else {
            return AnyView(
                HStack {
                    ButtonView(action: {
                        isShowingShoppingList = false
                    }, imageName: "back-icon")
                    Spacer()
                    ButtonView(action: {
                        // Manually add item to ShoppingList model
                    }, imageName: "add-icon")
                    Spacer()
                    ButtonView(action: {
                        isInEditMode.toggle()
                    }, imageName: "remove-icon")
                    Spacer()
                    ButtonView(action: {
                        removeAllProducts()
                    }, imageName: "delete-icon")
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 30)
                .frame(maxWidth: .infinity)
            )
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
