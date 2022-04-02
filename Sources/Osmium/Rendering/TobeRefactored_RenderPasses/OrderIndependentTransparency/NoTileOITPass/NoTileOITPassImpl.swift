//
// Created by Artem Sechko on 07.09.2021.
//

import Foundation
import Metal
/*
class NoTileOITPassImpl: RenderPass {
    private let metalConfig: MetalConfig

    private let data: NoTileOITData
    private let clearPass: NoTileOITClearPass
    private let accumulatePass: NoTileOITAccumulatePass
    private let compositePass: NoTileOITCompositePass

    init(withMetalConfig metalConfig: MetalConfig) {
        self.metalConfig = metalConfig
        data = NoTileOITData(withMetalConfig: metalConfig)
        clearPass = NoTileOITClearPass(withData: data)
        accumulatePass = NoTileOITAccumulatePass(withData: data)
        compositePass = NoTileOITCompositePass(withData: data)
    }

    func updateWithNodes(_ nodes: [OSMNode]) {
        accumulatePass.updateWithNodes(nodes)
    }

    func drawableSizeDidChange(withNewValue newValue: CGSize) {
        let simdSize: SIMD2<Int32> = [Int32(newValue.width), Int32(newValue.height)]
        data.reloadWithNewTargetSize(simdSize)
    }

    func execute(withCommandBuffer commandBuffer: MTLCommandBuffer,
                 renderTarget: RenderTarget,
                 encoderBoundUniforms: FrameConstantUniforms) {
        guard data.renderData != nil else {
            fatalError("Render target size did not set")
        }

        clearPass.execute(withCommandBuffer: commandBuffer)
        accumulatePass.execute(
                withCommandBuffer: commandBuffer,
                renderTarget: renderTarget,
                encoderBoundUniforms: encoderBoundUniforms
        )
        compositePass.execute(withCommandBuffer: commandBuffer, renderTarget: renderTarget)
    }
}*/
