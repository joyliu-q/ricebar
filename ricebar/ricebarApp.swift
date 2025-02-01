//
//  RicebarApp.swift
//  Ricebar
//
//  Created by Joy Liu on 11/3/24.
//

import SwiftUI


@main
struct RicebarApp: App {

    var body: some Scene {
        MenuBarExtra {
            Button(action: {
                PopoverManager.shared.toggle()
            }) {
                Text(PopoverManager.shared.isVisible ? "Hide Ricebar" : "Show Ricebar")
            }
        } label: {
            Image(systemName: "leaf.fill")
        }
        .menuBarExtraStyle(.window)

        .commands {
            CommandMenu("Ricebar") {
                Button(action: {
                    PopoverManager.shared.toggle()
                }) {
                    Text(PopoverManager.shared.isVisible ? "Hide Ricebar" : "Show Ricebar")
                }
                .keyboardShortcut("P", modifiers: [.command, .shift])
            }
        }
    }
}

