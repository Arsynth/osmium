//
// Created by Artem Sechko on 28.03.2021.
//

import Foundation
import MetalKit
import SwiftUI
import AppKit

private let kPreferredFPS = 60

public class OSMNSView: NSView, OSMSceneRenderer {
    public var scene: OSMScene {
        didSet {
            renderer.scene = scene
        }
    }
    public var pointOfView: OSMNode

    public var device: MTLDevice? {
        mtkView.device
    }

    private let mtkView: MTKView
    private let commandQueue: MTLCommandQueue
    private let renderer: OSMRenderer

    private let touchableView: TouchableView
    private let cameraController: LookAtCameraController
    private let eventHandler: ViewEventHandler

    public init(frame frameRect: CGRect,
                scene: OSMScene = OSMScene(),
                device: MTLDevice) {
        self.scene = scene

        let currentPointOfView: OSMNode
        if let cameraNode = scene.cameraNodes().first {
            currentPointOfView = cameraNode
        } else {
            currentPointOfView = Self.makeDefaultPointOfView()
            scene.rootNode.add(childNode: currentPointOfView)
        }
        pointOfView = currentPointOfView

        mtkView = MTKView(frame: frameRect)
        commandQueue = device.makeCommandQueue()!
        renderer = OSMRenderer(device: device, scene: scene, pointOfView: currentPointOfView)

        let cameraController = LookAtCameraController(withNode: scene.firstPointOfView)
        self.cameraController = cameraController
        let eventHandler = ViewEventHandler(
                keyboardInteractable: cameraController,
                mouseInteractable: cameraController,
                gestureInteractable: cameraController
        )
        self.eventHandler = eventHandler
        touchableView = TouchableView(frame: frameRect)
        touchableView.eventHandler = eventHandler

        super.init(frame: frameRect)

        renderer.scene = scene

        mtkView.device = device
        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.preferredFramesPerSecond = kPreferredFPS

        mtkView.depthStencilPixelFormat = .depth32Float
        mtkView.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        mtkView.delegate = self

        mtkView.framebufferOnly = false

        addSubview(mtkView)
        addSubview(touchableView)
    }

    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }

    public override func layout() {
        super.layout()
        mtkView.frame = bounds
        touchableView.frame = bounds
    }

    private static func makeDefaultPointOfView() -> OSMNode {
        let camera = OSMLookAtCamera()
        camera.near = 1.0
        camera.far = 2000.0
        let node = OSMNode(withCamera: camera)
        node.position = [0.0, 40.0, -40.0]
        return node
    }
}

extension OSMNSView: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        ///TODO: Remove this logic from view. It may be redundant at user logic
        pointOfView.camera?.aspect = Float(size.width / size.height)
        ///-------------------------------------
    }

    public func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else {
            return
        }

        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            print("Warning: could not create MTLCommandBuffer instance")
            return
        }

        guard let renderPassDescriptor = mtkView.currentRenderPassDescriptor else {
            print("No MTLRenderPassDescriptor for frame")
            return
        }

        renderer.render(atTime: .zero, viewport: bounds, commandBuffer: commandBuffer, passDescriptor: renderPassDescriptor)

        commandBuffer.present(drawable)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}

public struct OSMView: NSViewRepresentable {
    public typealias NSViewType = OSMNSView

    public let scene: OSMScene
    public let device: MTLDevice

    public init(withScene scene: OSMScene, device: MTLDevice) {
        self.scene = scene
        self.device = device
    }

    public func makeNSView(context: Context) -> OSMNSView {
        OSMNSView(frame: .zero, scene: scene, device: device)
    }

    public func updateNSView(_ nsView: OSMNSView, context: Context) {

    }
}
