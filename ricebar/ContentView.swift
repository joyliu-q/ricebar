//
//  ContentView.swift
//  ricebar
//
//  Created by Joy Liu on 11/3/24.
//

import SwiftUI

private var RICEBAR_TITLE = "Ricebar"
var RICEBAR_HEIGHT = CGFloat(30)

struct ContentView: View {
    @Binding var showRicebar: Bool
    
    @State var popoverWindow: NSWindow?

    var body: some View {
        VStack {
            Button("Toggle Ricebar") {
                showRicebar.toggle()            }
        }
        .onChange(of: showRicebar, initial: true) {
            if !showRicebar {
                NSApp.windows
                    .filter { $0.title == RICEBAR_TITLE }
                    .forEach { $0.close() }
            } else {
                showPopover()
            }
        }
    }

    func showPopover() {
        guard let screenFrame = NSScreen.main?.frame else { return }

        let window = NSWindow(
            contentRect: NSRect(x: screenFrame.minX,
                                y: screenFrame.maxY - RICEBAR_HEIGHT,
                                width: screenFrame.width,
                                height: RICEBAR_HEIGHT),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window.isReleasedWhenClosed = false
        window.title = RICEBAR_TITLE
        window.level = .mainMenu + 1
        window.isOpaque = false
        window.backgroundColor = .clear
        window.isReleasedWhenClosed = false
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        window.contentView = NSHostingView(rootView: MenuBarView {
            showRicebar = false
            window.close()
            popoverWindow = nil
        })
        window.makeKeyAndOrderFront(nil)
        popoverWindow = window
    }
}
