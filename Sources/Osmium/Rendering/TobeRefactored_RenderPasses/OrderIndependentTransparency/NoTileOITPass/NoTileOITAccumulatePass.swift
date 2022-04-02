//
// Created by Artem Sechko on 09.12.2021.
//

import Foundation
import Metal

/*
class NoTileOITAccumulatePass {
    private let data: NoTileOITData
    private let descriptor: MTLRenderPassDescriptor
    private let mainPass: BaseRenderPassImpl

    init(withData data: NoTileOITData) {
        self.data = data
        descriptor = Self.makeDescriptor()

        let psoController = StatesMapper(
                metalConfig: data.metalConfig,
                stateDescriptorFactory: FragListStateDescriptorFactoryImpl(withMetalConfig: data.metalConfig)
        )
        let renderableController = BaseRenderableControllerImpl.makeForTranslucent(withPSOController: psoController)
        let renderTraverse = RenderableHandler(
                withRenderableController: renderableController,
                sequenceFactory: RenderSequenceFactory(),
                defaultDepthStencilState: Self.makeDSState(withDevice: data.metalConfig.device)
        )
        mainPass = BaseRenderPassImpl(
                withMetalConfig: data.metalConfig,
                renderTraverse: renderTraverse
        )
    }

    func execute(withCommandBuffer commandBuffer: MTLCommandBuffer,
                 renderTarget: RenderTarget,
                 encoderBoundUniforms: FrameConstantUniforms) {
        guard let renderData = data.renderData else { return }

        descriptor.updateForAccumulate(withTarget: renderTarget)

        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            print("Failed to create render command encoder")
            return
        }

        let renderPassUniforms = UniformsFactory.makeOITRenderPassUniforms(
                withRenderPassDescriptor: descriptor,
                metalConfig: data.metalConfig
        )
        renderEncoder.setupRenderPassUniforms(renderPassUniforms, function: .fragment)
        renderEncoder.setupForAccumulation(withOITData: renderData)

        mainPass.execute(
                withRenderCommandEncoder: renderEncoder,
                renderTarget: renderTarget,
                encoderBoundUniforms: encoderBoundUniforms
        )

        renderEncoder.endEncoding()
    }

    func updateWithNodes(_ nodes: [OSMNode]) {
        mainPass.updateWithNodes(nodes)
    }

    private static func makeDescriptor() -> MTLRenderPassDescriptor {
        let newOITPassDescriptor = MTLRenderPassDescriptor()
        newOITPassDescriptor.colorAttachments[0].loadAction = .dontCare
        newOITPassDescriptor.colorAttachments[0].storeAction = .dontCare
        newOITPassDescriptor.depthAttachment.loadAction = .load
        newOITPassDescriptor.depthAttachment.storeAction = .dontCare

        /// Stored render pass descriptor should not retain target textures
        newOITPassDescriptor.colorAttachments[0].texture = nil
        newOITPassDescriptor.depthAttachment.texture = nil

        return newOITPassDescriptor
    }

    private static func makeDSState(withDevice device: MTLDevice) -> MTLDepthStencilState {
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = false
        return device.makeDepthStencilState(descriptor: depthStencilDescriptor)!
    }

}

private extension MTLRenderCommandEncoder {
    func setupForAccumulation(withOITData data: NoTileOITRenderData) {
        setFragmentBuffer(data.fragCounterBuffer, offset: 0, index: Int(BufferIndex.fragmentsCounter.rawValue))
        setFragmentBuffer(data.headsBuffer, offset: 0, index: Int(BufferIndex.fragmentHeads.rawValue))
        setFragmentBuffer(data.fragListBuffer, offset: 0, index: Int(BufferIndex.listItems.rawValue))
    }
}

private extension MTLRenderPassDescriptor {
    func updateForAccumulate(withTarget target: RenderTarget) {
        colorAttachments[0].texture = nil
        depthAttachment.texture = target.depthAttachment.texture
    }
}
*/
