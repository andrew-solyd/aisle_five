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
    
    var body: some View {
        VStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach($shoppingList.products) { $product in
                            Button(action: {
                                product.isChecked.toggle()
                            }) {
                                HStack {
                                    // Square box that toggles filled/empty state
                                    Image(systemName: product.isChecked ? "checkmark.square.fill" : "square")
                                        .foregroundColor(Color.systemFontColor)

                                    // Product name, strikethrough if the product is checked
                                    Text(product.name)
                                        .strikethrough(product.isChecked, color: .black)
                                        .font(Font.custom("Parclo Serif Medium", size: 18))
                                        .foregroundColor(Color.systemFontColor)
                                    
                                    Spacer()
                                    
                                    if isInEditMode {
                                        if let index = shoppingList.products.firstIndex(where: { $0.id == product.id }) {
                                            Button(action: {
                                                shoppingList.products.remove(at: index)
                                            }) {
                                                Image(systemName: "minus.circle")
                                                    .foregroundColor(.red)
                                                    .padding(.trailing, 10)
                                            }
                                        }
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
                        .padding(.horizontal, 15)
                    }
                }
                /*
                VStack {
                    LinearGradient(gradient: Gradient(colors: [Color.white.opacity(1.0), Color.white.opacity(0.0)]),
                                   startPoint: .top,
                                   endPoint: .bottom)
                        .frame(height: 100) // Adjust the height to control the fade-out length
                        .ignoresSafeArea(edges: .top)
                        .alignmentGuide(.top, computeValue: { _ in 0 })
                    Spacer()
                }
                */
            }
            if isInEditMode {
                Button("Done") {
                    isInEditMode.toggle()
                }
                .padding(30)
                .frame(maxWidth: .infinity)
            } else {
                HStack {
                    ButtonView(action: {
                        // Goes back to conversation view
                        isShowingShoppingList = false
                    }, imageName: "back-icon")
                    Spacer()
                    ButtonView(action: {
                        // Manually add item to ShoppingList model
                    }, imageName: "add-icon")
                    Spacer()
                    ButtonView(action: {
                        // Enter edit mode
                        isInEditMode.toggle()
                    }, imageName: "remove-icon")
                    Spacer()
                    ButtonView(action: {
                        shoppingList.products.removeAll()
                    }, imageName: "delete-icon")
                }
                .padding(30) // Padding of 30px around the HStack
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bodyColor)
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

