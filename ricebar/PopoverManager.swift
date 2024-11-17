//
//  PopoverManager.swift
//  ricebar
//
//  Created by Joy Liu on 11/11/24.
//

import AppKit
import SwiftUI

var RICEBAR_TITLE = "Ricebar"
var RICEBAR_HEIGHT = CGFloat(10)

// TODO: IDK HOW TO SOLVE NOTCH WIDTH DETECTION
class PopoverManager {
    static let shared = PopoverManager()
    private var popoverWindow: NSWindow?

    func showPopover() {
        guard let screenFrame = NSScreen.main?.frame else { return }
        
        let notchWidth = CGFloat(210)
        let halfScreenWidth = screenFrame.width / 2
        let xPosition = screenFrame.midX + notchWidth / 2
        
        let popoverWidth = halfScreenWidth - notchWidth / 2
        
        let window = NSWindow(
            contentRect: NSRect(x: xPosition,
                                y: screenFrame.maxY - RICEBAR_HEIGHT,
                                width: popoverWidth,
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
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        window.contentView = NSHostingView(rootView: MenuBarView {
            self.hidePopover()
        })
        window.makeKeyAndOrderFront(nil)
        popoverWindow = window
    }

    func hidePopover() {
        popoverWindow?.close()
        popoverWindow = nil
    }
}
