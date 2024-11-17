//
//  RicebarApp.swift
//  Ricebar
//
//  Created by Joy Liu on 11/3/24.
//

import SwiftUI

@main
struct RicebarApp: App {
    @State private var showRicebar = false

    var body: some Scene {
        MenuBarExtra {
            // The content inside the Menu Bar Extra
            Button(action: {
                showRicebar.toggle()
            }) {
                Text(showRicebar ? "Hide Ricebar" : "Show Ricebar")
            }
        } label: {
            // The icon shown in the menu bar
            Image(systemName: "leaf.fill")
        }
        .menuBarExtraStyle(.window) // Optional: Choose the style of the menu bar extra

        // Add keyboard shortcut
        .commands {
            CommandMenu("Ricebar") {
                Button(action: {
                    showRicebar.toggle()
                }) {
                    Text(showRicebar ? "Hide Ricebar" : "Show Ricebar")
                }
                .keyboardShortcut("P", modifiers: [.command, .shift])
            }
        }
        .onChange(of: showRicebar, {
            if showRicebar {
                PopoverManager.shared.showPopover()
            } else {
                PopoverManager.shared.hidePopover()
            }
        })
    }
}

