//
// Created by Artem Sechko on 15.05.2021.
//

import Foundation
import CoreGraphics
import simd

class LookAtCameraController: ObjectController {
    public var keyboardInteractable: KeyboardInteractable? { self }
    public var mouseInteractable: MouseInteractable? { self }
    public var gestureInteractable: GestureInteractable? { self }

    let node: OSMNode
    let camera: OSMLookAtCamera?

    var translationSpeed: Float = 10.0
    var rotationSpeed: Float = 1.0
    var yaw: Float = 90.0
    var pitch: Float = -45.0

    fileprivate var cameraDirection: float3 {
        var direction = float3(repeating: 0.0)
        direction.x =  cos(yaw.degreesToRadians) * cos(pitch.degreesToRadians)
        direction.y = sin(pitch.degreesToRadians)
        direction.z = sin(yaw.degreesToRadians) * cos(pitch.degreesToRadians)
        return direction
    }
    private var directionKeysDown: Set<KeyboardControl> = []

    public init(withNode node: OSMNode) {
        self.node = node
        /// Temporary fix. This controller will control node directly and will not be generic
        camera = node.camera as? OSMLookAtCamera
        camera?.front = normalize(cameraDirection)
    }
}

extension LookAtCameraController: KeyboardInteractable {
    public func keyPressed(key: KeyboardControl, state: InputState) -> Bool {
        if state == .began {
            directionKeysDown.insert(key)
        }
        if state == .ended {
            directionKeysDown.remove(key)
        }

        return true
    }
}

extension LookAtCameraController: MouseInteractable {
    public func mouseEvent(mouse: MouseControl, state: InputState, delta: float3, location: float2) {

    }
}

extension LookAtCameraController: GestureInteractable {
    public func translation(withPoint point: CGPoint) {
//        https://learnopengl.com/Getting-started/Camera

        let delta = float2(Float(-point.x), Float(point.y)) * 0.1
        yaw += delta.x
        pitch += delta.y
        pitch = max(min(pitch, 89.0), -89.0)

        camera?.front = normalize(cameraDirection)
    }

    public func scroll(withDeltaX dX: CGFloat, dY: CGFloat, dZ: CGFloat) {
        guard let camera = camera else { return }

        var direction = float3(Float(-dX), Float(dY), Float(dZ))
        guard direction != [0.0, 0.0, 0.0] else {
            return
        }
        direction = normalize(direction)
        let change = (direction.y * camera.up + direction.x * camera.right) * 0.5
        node.position += change
    }

    public func magnify(withDelta delta: CGFloat) {
        guard let camera = camera else { return }
        node.position += camera.front * Float(delta * 10.0)
    }
}

extension LookAtCameraController: OSMModelTiming {
    public func updateWithTime(_ time: CFAbsoluteTime) {
        /*
        let translationSpeed = Float(deltaTime) * translationSpeed
        let rotationSpeed = Float(deltaTime) * rotationSpeed
        var direction: float3 = [0.0, 0.0, 0.0]
        for key in directionKeysDown {
            switch key {
            case .w:
                direction.y += 1
            case .a:
                direction.x -= 1
            case .s:
                direction.y -= 1
            case .d:
                direction.x += 1
            case .left, .q:
                node.rotation.y -= rotationSpeed
            case .right, .e:
                node.rotation.y += rotationSpeed
            default:
                break
            }
        }
        if direction != [0, 0, 0] {
            direction = normalize(direction)
            let change = (direction.y * camera.up + direction.x * camera.right) * translationSpeed
            node.position += change
        }
        */
    }
}
