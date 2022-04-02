//
//  TouchesView.swift
//  OsmiumDevApp
//
//  Created by Artem Sechko on 23.01.2022.
//

import SwiftUI
import AppKit
import simd

public class TouchableView: NSView {
    var useMouse = false {
        didSet {
            eventHandler?.useMouse = useMouse
        }
    }

    var eventHandler: ViewEventHandler?

    // MARK: - NSResponder
    public override var acceptsFirstResponder: Bool {
        true
    }

    override init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        setupRecognizers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupRecognizers()
    }

    @objc func handlePan(gesture: NSPanGestureRecognizer) {
        eventHandler?.handlePan(gesture: gesture)
        gesture.setTranslation(.zero, in: gesture.view)
    }

    public override func scrollWheel(with event: NSEvent) {
        eventHandler?.scrollWheel(with: event)
    }

    public override func magnify(with event: NSEvent) {
        super.magnify(with: event)
        if event.phase == .changed {
            eventHandler?.magnify(with: event)
        }
    }

    public override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        true
    }

    public override func keyDown(with event: NSEvent) {
        /*guard let key = KeyboardControl(rawValue: event.keyCode) else {
            return
        }
        let state: InputState = event.isARepeat ? .continued : .began
        eventHandler?.processEvent(key: key, state: state)*/
    }

    public override func keyUp(with event: NSEvent) {
        /*guard let key = KeyboardControl(rawValue: event.keyCode) else {
            return
        }
        eventHandler?.processEvent(key: key, state: .ended)*/
    }

    public override func mouseMoved(with event: NSEvent) {
        eventHandler?.processEvent(mouse: .mouseMoved, state: .began, event: event)
        // reset mouse position to center of view
        guard useMouse else { return }
        let screenFrame = NSScreen.main?.frame ?? .zero
        var rect = frame
        frame = convert(rect, to: nil)
        rect = window?.convertToScreen(rect) ?? rect
        CGWarpMouseCursorPosition(NSPoint(x: (rect.origin.x + bounds.midX),
                y: (screenFrame.height - rect.origin.y - bounds.midY) ))
    }


    public override func mouseDown(with event: NSEvent) {
        eventHandler?.processEvent(mouse: .leftDown, state: .began, event: event)
    }

    public override func mouseUp(with event: NSEvent) {
        eventHandler?.processEvent(mouse: .leftUp, state: .ended, event: event)
    }

    public override func mouseDragged(with event: NSEvent) {
        eventHandler?.processEvent(mouse: .leftDrag, state: .continued, event: event)
    }

    public override func rightMouseDown(with event: NSEvent) {
        eventHandler?.processEvent(mouse: .rightDown, state: .began, event: event)
    }

    public override func rightMouseDragged(with event: NSEvent) {
        eventHandler?.processEvent(mouse: .rightDrag, state: .continued, event: event)
    }

    public override func rightMouseUp(with event: NSEvent) {
        eventHandler?.processEvent(mouse: .rightUp, state: .ended, event: event)
    }

    private func setupRecognizers() {
        let pan = NSPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        addGestureRecognizer(pan)
    }
}
