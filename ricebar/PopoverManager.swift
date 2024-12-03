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
    private var isAnimating = false
    
    func showPopover() {
        guard !isAnimating else { return }
        guard let screenFrame = NSScreen.main?.frame else { return }
        
        let notchWidth = CGFloat(210)
        let halfScreenWidth = screenFrame.width / 2
        let xPosition = screenFrame.midX + notchWidth / 2
        
        let popoverWidth = halfScreenWidth - notchWidth / 2
        
        let window = NSPanel(
            contentRect: NSRect(x: xPosition,
                                y: screenFrame.maxY - RICEBAR_HEIGHT,
                                width: popoverWidth,
                                height: RICEBAR_HEIGHT),
            styleMask: [.borderless, .nonactivatingPanel],
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
        window.hasShadow = false
        
        isAnimating = true
        if let contentView = window.contentView {
            contentView.wantsLayer = true
            contentView.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            applyRollingAnimation(to: contentView, isShowing: true) {
                self.isAnimating = false
            }
        }

        window.makeKeyAndOrderFront(nil)
        popoverWindow = window
    }

    func hidePopover() {
        guard !isAnimating, let popoverWindow = popoverWindow, let contentView = popoverWindow.contentView else {
            return
        }
        isAnimating = true
        applyRollingAnimation(to: contentView, isShowing: false) {
            self.popoverWindow?.close()
            self.popoverWindow = nil
            self.isAnimating = false
        }
    }
    
    private func applyRollingAnimation(to view: NSView, isShowing: Bool, completion: (() -> Void)? = nil) {
            let animation = CABasicAnimation(keyPath: "transform.rotation.y")
            animation.fromValue = isShowing ? CGFloat.pi : 0
            animation.toValue = isShowing ? 0 : CGFloat.pi
            animation.duration = 0.5
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false

            CATransaction.begin()
            CATransaction.setCompletionBlock {
                completion?()
            }
            view.layer?.add(animation, forKey: "rollAnimation")
            CATransaction.commit()
        }
}
