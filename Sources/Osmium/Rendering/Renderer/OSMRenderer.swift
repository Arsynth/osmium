//
// Created by Artem Sechko on 27.03.2021.
//

import Foundation
import Metal
import MetalKit

public class OSMRenderer: OSMSceneRenderer {
    let device: MTLDevice

    public var scene: OSMScene {
        didSet {
            renderPass.scene = scene
        }
    }
    public var pointOfView: OSMNode

    private let renderPass: RenderPass

    public init(device: MTLDevice?, scene: OSMScene, pointOfView: OSMNode? = nil) {
        if let device = device {
            self.device = device
        } else {
            guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
                fatalError("GPU not available")
            }
            self.device = defaultDevice
        }
        self.scene = scene
        let pointOfView = pointOfView ?? scene.firstPointOfView
        self.pointOfView = pointOfView

        renderPass = RenderPass(scene: scene, pointOfView: pointOfView)
    }

    public func render(atTime: CFTimeInterval,
                viewport: CGRect,
                commandBuffer: MTLCommandBuffer,
                passDescriptor: MTLRenderPassDescriptor) {
        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor) else {
            print("Failed to create render command encoder")
            return
        }

        renderPass.execute(
                withRenderCommandEncoder: renderCommandEncoder,
                passDescriptor: passDescriptor
        )

        renderCommandEncoder.endEncoding()
    }
}
