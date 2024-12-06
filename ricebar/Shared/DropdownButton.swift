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
    let title: String
    @State private var isPresented: Bool = false
    let content: () -> Content

    init(iconName: String, title: String = "Menu", @ViewBuilder content: @escaping () -> Content) {
        self.iconName = iconName
        self.title = title
        self.content = content
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
            DropdownMenu(isPresented: $isPresented, title: title, content: content)
        }
        .background(.clear)
    }
}

struct DropdownMenu<Content: View>: View {
    @Binding var isPresented: Bool
    let title: String
    let content: () -> Content

    init(isPresented: Binding<Bool>, title: String = "Menu", @ViewBuilder content: @escaping () -> Content) {
        self._isPresented = isPresented
        self.title = title
        self.content = content
    }

    var body: some View {
        ZStack {
            DEFAULT_BACKGROUND.edgesIgnoringSafeArea(.all).timeVaryingShader()
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.defaultAccent)
                    Spacer()
                }
                .padding([.horizontal, .top])
                Divider()
                    .background(.defaultAccent)
                content() 
                    .padding([.horizontal, .bottom])
            }
            .frame(maxWidth: 200)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.spring(), value: isPresented)
        }
    }
}
