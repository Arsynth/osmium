//
// Created by Artem Sechko on 04.10.2021.
//

import Foundation
import Metal
/*
private let kCubeResolution: Int = 1024

class ReflectionPassImpl: RenderPass, EncoderSharingPass {
    var nextRenderPass: EncoderReusingPass? {
        get {
            mainRenderPass.nextRenderPass
        } set {
            mainRenderPass.nextRenderPass = newValue
        }
    }

    private let metalConfig: MetalConfig
    private let renderableController: RenderableController
    private let cubeGenerator: CubeGenerator
    private let mainRenderPass: BaseRenderPassImpl

    init(withMetalConfig metalConfig: MetalConfig) {
        self.metalConfig = metalConfig

        let renderableController = BaseRenderableControllerImpl.makeForReflective(withMetalConfig: metalConfig)
        self.renderableController = renderableController
        let traverse = RenderableHandler(
                withRenderableController: renderableController,
                sequenceFactory: RenderSequenceFactory(),
                defaultDepthStencilState: CommonStatesFactory.defaultDepthStencilState(withMetalConfig: metalConfig)!
        )
        cubeGenerator = CubeGenerator(withMetalConfig: metalConfig, cubesResolution: kCubeResolution)
        mainRenderPass = BaseRenderPassImpl(
                withMetalConfig: metalConfig,
                renderTraverse: traverse
        )
    }

    func updateWithNodes(_ nodes: [OSMNode]) {
        renderableController.updateWithNodes(nodes)
        cubeGenerator.updateWithReflectiveRenderables(
                renderableController.renderables,
                reflectedNodes: nodes
        )
        renderableController.syncPipelineStates()
    }

    func drawableSizeDidChange(withNewValue newValue: CGSize) {

    }

    func execute(withCommandBuffer commandBuffer: MTLCommandBuffer,
                 renderTarget: RenderTarget,
                 encoderBoundUniforms: FrameConstantUniforms) {
        cubeGenerator.generate(
                withCommandBuffer: commandBuffer,
                encoderBoundUniforms: encoderBoundUniforms
        )

        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderTarget) else {
            print("Failed to create render command encoder")
            return
        }
        execute(
                withRenderCommandEncoder: renderCommandEncoder,
                renderTarget: renderTarget,
                encoderBoundUniforms: encoderBoundUniforms
        )

        renderCommandEncoder.endEncoding()
    }

    func execute(withRenderCommandEncoder renderCommandEncoder: MTLRenderCommandEncoder,
                 renderTarget: RenderTarget,
                 encoderBoundUniforms: FrameConstantUniforms) {
        mainRenderPass.execute(
                withRenderCommandEncoder: renderCommandEncoder,
                renderTarget: renderTarget,
                encoderBoundUniforms: encoderBoundUniforms
        )
    }
}
*/
