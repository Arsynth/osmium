//
// Created by Artem Sechko on 09.12.2021.
//

import Foundation
import Metal

/*
class NoTileOITCompositePass {
    private let data: NoTileOITData
    private let descriptor: MTLRenderPassDescriptor
    private let dsState: MTLDepthStencilState
    private let pipelineState: MTLRenderPipelineState

    init(withData data: NoTileOITData) {
        self.data = data
        descriptor = Self.makeDescriptor()
        dsState = Self.makeDSState(withDevice: data.metalConfig.device)
        pipelineState = Self.makePSO(withRenderConfig: data.metalConfig)
    }

    func execute(withCommandBuffer commandBuffer: MTLCommandBuffer, renderTarget: RenderTarget) {
        guard let renderData = data.renderData else { return }
        descriptor.updateWithTarget(renderTarget)

        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            print("Failed to create render command encoder")
            return
        }

        renderEncoder.setDepthStencilState(dsState)
        renderEncoder.setRenderPipelineState(pipelineState)
        let renderPassUniforms = UniformsFactory.makeOITRenderPassUniforms(
                withRenderPassDescriptor: descriptor,
                metalConfig: data.metalConfig
        )
        renderEncoder.setupRenderPassUniforms(renderPassUniforms, function: .fragment)
        renderEncoder.setupForComposition(withOITData: renderData)
        renderEncoder.setVertexBuffer(data.quadVertexBuffer, offset: 0, index: Int(BufferIndex.vertices.rawValue))

        renderEncoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: NoTileOITData.quadIndices.count,
                indexType: .uint16,
                indexBuffer: data.quadIndexBuffer,
                indexBufferOffset: 0
        )

        renderEncoder.endEncoding()
    }

    private static func makeDescriptor() -> MTLRenderPassDescriptor {
        /// Stored render pass descriptor should not retain target textures
        let newOITPassDescriptor = MTLRenderPassDescriptor()
        newOITPassDescriptor.colorAttachments[0].loadAction = .load
        newOITPassDescriptor.colorAttachments[0].storeAction = .store
        newOITPassDescriptor.depthAttachment.loadAction = .dontCare
        newOITPassDescriptor.depthAttachment.storeAction = .dontCare

        /// Stored render pass descriptor should not retain target textures
        newOITPassDescriptor.colorAttachments[0].texture = nil
        newOITPassDescriptor.depthAttachment.texture = nil

        return newOITPassDescriptor
    }

    private static func makeDSState(withDevice device: MTLDevice) -> MTLDepthStencilState {
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .always
        depthStencilDescriptor.isDepthWriteEnabled = false
        return device.makeDepthStencilState(descriptor: depthStencilDescriptor)!
    }

    private static func makePSO(withRenderConfig config: MetalConfig) -> MTLRenderPipelineState {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = config.library.makeFunction(name: "composeOITVertex")
        descriptor.fragmentFunction = config.library.makeFunction(name: "composeOITFragment")
        descriptor.depthAttachmentPixelFormat = config.depthStencilPixelFormat
        descriptor.colorAttachments[0].pixelFormat = config.colorPixelFormat

        descriptor.colorAttachments[0].pixelFormat = config.colorPixelFormat
        descriptor.colorAttachments[0].isBlendingEnabled = true
        descriptor.colorAttachments[0].rgbBlendOperation = .add
        descriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha

        return try! config.device.makeRenderPipelineState(descriptor: descriptor)
    }
}

private extension MTLRenderCommandEncoder {
    func setupForComposition(withOITData data: NoTileOITRenderData) {
        setFragmentBuffer(data.headsBuffer, offset: 0, index: Int(BufferIndex.fragmentHeads.rawValue))
        setFragmentBuffer(data.fragListBuffer, offset: 0, index: Int(BufferIndex.listItems.rawValue))
    }
}

private extension MTLRenderPassDescriptor {
    func updateWithTarget(_ target: RenderTarget) {
        colorAttachments[0].texture = target.colorAttachments[0].texture
        colorAttachments[0].clearColor = target.colorAttachments[0].clearColor
        colorAttachments[0].slice = target.colorAttachments[0].slice
        depthAttachment.texture = target.depthAttachment.texture
        depthAttachment.clearDepth = target.depthAttachment.clearDepth
        depthAttachment.slice = target.depthAttachment.slice
    }
}
*/
