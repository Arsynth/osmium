//
//  NSViewEventHandler.swift
//  OsmiumDevApp
//
//  Created by Artem Sechko on 23.01.2022.
//

import Foundation
import AppKit
import simd

class ViewEventHandler {
    var translationSpeed: Float = 2.0
    var rotationSpeed: Float = 1.0

    var useMouse = false

    let keyboardInteractable: KeyboardInteractable?
    let mouseInteractable: MouseInteractable?
    let gestureInteractable: GestureInteractable?

    init(keyboardInteractable: KeyboardInteractable?,
         mouseInteractable: MouseInteractable?,
         gestureInteractable: GestureInteractable?) {
        self.keyboardInteractable = keyboardInteractable
        self.mouseInteractable = mouseInteractable
        self.gestureInteractable = gestureInteractable
    }

    func processEvent(key inKey: KeyboardControl, state: InputState) {
        let _ = keyboardInteractable?.keyPressed(key: inKey, state: state)
    }

    func processEvent(mouse: MouseControl, state: InputState, event: NSEvent) {
        let delta: float3 = [Float(event.deltaX), Float(event.deltaY), Float(event.deltaZ)]
        let locationInWindow: float2 = [Float(event.locationInWindow.x), Float(event.locationInWindow.y)]
        mouseInteractable?.mouseEvent(mouse: mouse, state: state, delta: delta, location: locationInWindow)
    }

    func handlePan(gesture: NSPanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view)
        gestureInteractable?.translation(withPoint: translation)
    }

    func scrollWheel(with event: NSEvent) {
        gestureInteractable?.scroll(withDeltaX: event.deltaX, dY: event.deltaY, dZ: event.deltaZ)
    }

    func magnify(with event: NSEvent) {
        gestureInteractable?.magnify(withDelta: event.magnification)
    }
}
