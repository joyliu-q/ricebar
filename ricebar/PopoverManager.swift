//
//  PopoverManager.swift
//  ricebar
//
//  Created by Joy Liu on 11/11/24.
//

import AppKit
import SwiftUI

/// Constants (replace with the appropriate real values for your app)
private let RICEBAR_TITLE = "Ricebar"
private let RICEBAR_HEIGHT: CGFloat = 10

// TODO: Properly detect notch width instead of hardcoding:
private let DEFAULT_NOTCH_WIDTH: CGFloat = 210

/// A manager class responsible for showing/hiding a popover-like NSPanel
/// and handling keyboard-based movement (e.g., for Pong).
final class PopoverManager {
    static let shared = PopoverManager()
    
    /// Panel window that simulates the popover
    private(set) var popoverWindow: NSWindow?
    
    /// Whether an animation (show/hide) is currently in progress
    private var isAnimating = false
    
    /// Tracks the visible state of the popover
    private(set) var isVisible: Bool = false
    
    /// Observation token for window movement notifications
    private var windowObserver: Any?
    
    /// A repeating timer for continuous movement (arrow key “hold-down”)
    private var moveTimer: Timer?
    
    /// A local event monitor that listens for keyboard events
    private var keyboardMonitor: Any?
    
    /// The step size for incremental movement. Larger value => faster movement
    private let moveStep: CGFloat = 15.0
    
    /// The default X position on screen (i.e., top-right or near the notch)
    private var originalXPosition: CGFloat?
    
    /// Current direction of movement (-1 for left, 1 for right, 0 for none).
    private var currentDirection: CGFloat = 0

    /// Toggles the popover’s visibility.
    /// - Parameter visible: If provided, forces the popover to that visibility state. Otherwise, toggles.
    func toggle(visible: Bool? = nil) {
        guard !isAnimating else { return }
        
        if let forcedVisible = visible {
            isVisible = forcedVisible
        } else {
            isVisible.toggle()
        }
        
        if isVisible {
            showPopover()
        } else {
            hidePopover()
        }
    }
    
    /// Moves the popover left/right (for Pong).
    /// - Parameter direction: Positive = move right, Negative = move left.
    private func move(direction: CGFloat) {
        guard let window = popoverWindow, let screen = NSScreen.main else { return }
        
        // If Pong window is closed, reset position to original
        let isPongOpen = NSApp.windows.contains(where: { $0.title == "Pong" })
        if !isPongOpen, let original = originalXPosition {
            var frame = window.frame
            frame.origin.x = original
            window.setFrame(frame, display: true)
            return
        }
        
        var frame = window.frame
        frame.origin.x += direction * moveStep
        
        let minX: CGFloat = 0
        let maxX: CGFloat = screen.frame.width - frame.width
        frame.origin.x = max(minX, min(frame.origin.x, maxX))
        
        window.setFrame(frame, display: true)
        PongView.updatePaddlePosition(frame.midX)
    }
    
    /// Moves the popover to a percentage along the screen width (0.0 to 1.0).
    /// - Parameter percentage: 0.0 = left edge, 1.0 = right edge.
    func move(percentage: CGFloat) {
        guard let window = popoverWindow, let screen = NSScreen.main else { return }
        
        var frame = window.frame
        let clampedPercentage = max(0.0, min(percentage, 1.0))
        frame.origin.x = (screen.frame.width - frame.width) * clampedPercentage
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            window.animator().setFrame(frame, display: true)
        }
    }
    
    /// Resets the popover’s position back to the original point near the notch (or top-right).
    func resetPosition() {
        guard let window = popoverWindow, let original = originalXPosition else { return }
        
        var frame = window.frame
        frame.origin.x = original
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            window.animator().setFrame(frame, display: true)
        }
    }
}

// MARK: - Show/Hide
private extension PopoverManager {
    
    func showPopover() {
        guard !isAnimating else { return }
        guard let screenFrame = NSScreen.main?.frame else { return }
        
        // Hardcoded notch width. Replace with real detection if needed.
        let notchWidth = DEFAULT_NOTCH_WIDTH
        let halfScreenWidth = screenFrame.width / 2
        
        let xPosition = screenFrame.midX + notchWidth / 2
        originalXPosition = xPosition
        
        // The width from the screen’s midpoint to the right edge minus half the notch
        let popoverWidth = halfScreenWidth - (notchWidth / 2)
        
        let window = NSPanel(
            contentRect: NSRect(
                x: xPosition,
                y: screenFrame.maxY - RICEBAR_HEIGHT,
                width: popoverWidth,
                height: RICEBAR_HEIGHT
            ),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        window.isReleasedWhenClosed = false
        window.title = RICEBAR_TITLE
        window.level = .mainMenu + 1  // Above regular windows but below status menu
        window.isOpaque = false
        window.backgroundColor = NSColor(deviceRed: 0, green: 0, blue: 0, alpha: 0)
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        window.hasShadow = false
        window.isMovableByWindowBackground = true
        
        window.contentView = NSHostingView(rootView: MenuBarView {
            self.hidePopover()
        })
        
        // Start show animation
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
    }
    
    func hidePopover() {
        guard !isAnimating, let popoverWindow = popoverWindow,
              let contentView = popoverWindow.contentView else {
            return
        }
        
        // Stop any movement timer
        stopMoving()
        
        isAnimating = true
        applyRollingAnimation(to: contentView, isShowing: false) {
            // Once animation is done, close the window
            popoverWindow.close()
            self.popoverWindow = nil
            self.isAnimating = false
        }
        
        // Remove observer to prevent memory leaks
        if let observer = windowObserver {
            NotificationCenter.default.removeObserver(observer)
            windowObserver = nil
        }
        
        // Remove keyboard monitoring
        removeKeyboardMonitor()
    }
    
    /// 3D rotation ("rolling") animation around the y-axis.
    /// - Parameters:
    ///   - view: The NSView to animate
    ///   - isShowing: If true, rotates from π to 0; if false, from 0 to π
    ///   - completion: Called after the animation completes
    func applyRollingAnimation(to view: NSView,
                               isShowing: Bool,
                               completion: (() -> Void)? = nil) {
        let animation = CABasicAnimation(keyPath: "transform.rotation.y")
        animation.fromValue = isShowing ? CGFloat.pi : 0
        animation.toValue   = isShowing ? 0 : CGFloat.pi
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

// MARK: - Keyboard Monitoring
extension PopoverManager {
    
    /// Sets up a local keyboard monitor to listen for arrow key presses and
    /// move the popover left/right for Pong.
    func setupKeyboardMonitor() {
        // KeyDown monitor
        keyboardMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return event }
            switch event.keyCode {
            case 123: // Left arrow
                self.startMoving(direction: -1)
                return nil
            case 124: // Right arrow
                self.startMoving(direction: 1)
                return nil
            default:
                return event
            }
        }
        
        // KeyUp monitor
        NSEvent.addLocalMonitorForEvents(matching: .keyUp) { [weak self] event in
            guard let self = self else { return event }
            switch event.keyCode {
            case 123, 124:
                self.stopMoving()
                return nil
            default:
                return event
            }
        }
    }
    
    /// Removes the keyboard monitor and stops any ongoing movement.
    func removeKeyboardMonitor() {
        if let monitor = keyboardMonitor {
            NSEvent.removeMonitor(monitor)
            keyboardMonitor = nil
        }
        stopMoving()
    }
    
    /// Starts the auto-repeat movement timer in a specified direction.
    private func startMoving(direction: CGFloat) {
        currentDirection = direction
        moveTimer?.invalidate()
        
        moveTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0,
                                         repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.move(direction: direction)
        }
    }
    
    /// Stops any ongoing movement by invalidating the timer.
    private func stopMoving() {
        moveTimer?.invalidate()
        moveTimer = nil
        currentDirection = 0
    }
}
