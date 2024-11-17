//
//  DropdownButton.swift
//  ricebar
//
//  Created by Joy Liu on 11/17/24.
//

import SwiftUI
import IOKit.ps
import IOKit
import Network

struct DropdownOption {
    let label: String
    let action: () -> Void
}

struct DropdownButton<Content: View>: View {
    let iconName: String
    @State private var isPresented: Bool = false
    @State private var content: Content

    init(iconName: String, @ViewBuilder content: () -> Content) {
        self.iconName = iconName
        self.content = content()
    }

    var body: some View {
        Button(action: { isPresented.toggle() }) {
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(.white)
        }
        .buttonStyle(PlainButtonStyle())
        .popover(
            isPresented: $isPresented,
            attachmentAnchor: .rect(.bounds)
        ) {
            DropdownMenu(isPresented: $isPresented) {content}
        }.background(.clear)
    }
}


struct DropdownMenu<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content
    let title: String

    init(isPresented: Binding<Bool>, title: String = "Menu", @ViewBuilder content: () -> Content) {
            self._isPresented = isPresented
            self.title = title
            self.content = content()
        }

    var body: some View {
        ZStack {
            DEFAULT_BACKGROUND.edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.defaultAccent)
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.defaultAccent)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                }
                .padding([.horizontal, .top])
                Divider()
                    .background(.defaultAccent)
                content
                    .padding([.horizontal, .bottom])
            }
            .frame(maxWidth: 200)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.spring(), value: isPresented)
        }
    }
}

#Preview {
    DropdownMenu(isPresented: .constant(true)) {
               VStack {
                   Text("Option 1")
                       .onTapGesture { print("Option 1 selected") }
                       .foregroundColor(.defaultAccent)
                   Text("Option 2")
                       .onTapGesture { print("Option 2 selected") }
                       .foregroundColor(.defaultAccent)
                   Text("Option 3")
                       .onTapGesture { print("Option 3 selected") }
                       .foregroundColor(.defaultAccent)
               }
           }
           .background(DEFAULT_BACKGROUND)
}
