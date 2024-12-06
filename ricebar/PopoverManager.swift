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
    var popoverWindow: NSWindow?
    private var isAnimating = false
    private var windowObserver: Any?
    private let moveStep: CGFloat = 30.0 
    private var keyboardMonitor: Any?
    private var originalPosition: CGFloat?
    
    func showPopover() {
        guard !isAnimating else { return }
        guard let screenFrame = NSScreen.main?.frame else { return }
        
        let notchWidth = CGFloat(210)
        let halfScreenWidth = screenFrame.width / 2
        let xPosition = screenFrame.midX + notchWidth / 2
        originalPosition = xPosition
        
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
        window.backgroundColor = NSColor(deviceRed: 0, green: 0, blue: 0, alpha: 0)
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        window.contentView = NSHostingView(rootView: MenuBarView {
            self.hidePopover()
        })
        window.hasShadow = false
        
        window.isMovableByWindowBackground = true
        
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

        windowObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            guard let windowPosition = self?.popoverWindow?.frame.midX else { return }
            PongView.updatePaddlePosition(windowPosition)
        }

        setupKeyboardMonitor()
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

        if let observer = windowObserver {
            NotificationCenter.default.removeObserver(observer)
            windowObserver = nil
        }

        removeKeyboardMonitor()
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

    func moveWindow(direction: CGFloat) {
        guard let window = popoverWindow,
              let screen = NSScreen.main else { return }
        
        let isPongOpen = NSApp.windows.contains(where: { $0.title == "Pong" })
        if !isPongOpen, let originalPosition = originalPosition {
            var frame = window.frame
            frame.origin.x = originalPosition
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.3
                window.animator().setFrame(frame, display: true)
            }
            return
        }
        
        var frame = window.frame
        frame.origin.x += direction * moveStep
        frame.origin.x = max(0, min(frame.origin.x, screen.frame.width - frame.width))
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.1
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            window.animator().setFrame(frame, display: true)
        }
        
        PongView.updatePaddlePosition(frame.midX)
    }

    private func setupKeyboardMonitor() {
        keyboardMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            switch event.keyCode {
            case 123:
                self?.moveWindow(direction: -1)
                return nil
            case 124:
                self?.moveWindow(direction: 1)
                return nil
            default:
                return event
            }
        }
    }
    
    private func removeKeyboardMonitor() {
        if let monitor = keyboardMonitor {
            NSEvent.removeMonitor(monitor)
            keyboardMonitor = nil
        }
    }

    func resetPosition() {
        guard let window = popoverWindow,
              let originalPosition = originalPosition else { return }
        
        var frame = window.frame
        frame.origin.x = originalPosition
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            window.animator().setFrame(frame, display: true)
        }
    }
}

