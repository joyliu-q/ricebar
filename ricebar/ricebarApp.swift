//
//  ricebarApp.swift
//  ricebar
//
//  Created by Joy Liu on 11/3/24.
//

import SwiftUI

/// https://danielsaidi.com/blog/2023/11/22/customizing-the-macos-menu-bar-in-swiftui
/// https://github.com/siteline/swiftui-introspect
@main
struct 🍚: App {
    @State private var showRicebar = false

    var body: some Scene {
        WindowGroup {
            ContentView(showRicebar: $showRicebar)
        }
        .commands {
            CommandMenu("Ricebar") {
                Button(action: {
                    showRicebar.toggle()
                }) {
                    Text(showRicebar ? "Hide" : "Show")
                }
                .keyboardShortcut("P", modifiers: [.command, .shift])
            }
        }
    }
}
