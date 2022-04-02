//
// Created by Artem Sechko on 09.12.2021.
//

import Foundation
import Metal

/*
class NoTileOITClearPass {
    private let data: NoTileOITData

    init(withData data: NoTileOITData) {
        self.data = data
    }

    func execute(withCommandBuffer commandBuffer: MTLCommandBuffer) {
        resetCounter()
        clearHeads(withCommandBuffer: commandBuffer)
    }

    private func clearHeads(withCommandBuffer commandBuffer: MTLCommandBuffer) {
        guard let renderData = data.renderData else { return }

        let device = data.metalConfig.device
        let function = data.metalConfig.library.makeFunction(name: "clearHeads")!
        let clearHeadsPSO = try! device.makeComputePipelineState(function: function)

        var threadsPerGroup = clearHeadsPSO.maxTotalThreadsPerThreadgroup
        if threadsPerGroup > renderData.headsCount {
            threadsPerGroup = renderData.headsCount
        }
        let gridSize = MTLSizeMake(renderData.headsCount, 1, 1)

        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        commandEncoder.setComputePipelineState(clearHeadsPSO)
        commandEncoder.setBuffer(renderData.headsBuffer, offset: 0, index: 0)

        commandEncoder.dispatchThreads(gridSize, threadsPerThreadgroup: MTLSizeMake(threadsPerGroup, 1, 1))
        commandEncoder.endEncoding()
    }

    private func resetCounter() {
        guard let renderData = data.renderData else { return }
        let ptr = renderData.fragCounterBuffer.contents().bindMemory(to: UInt32.self, capacity: 1)
        ptr.pointee = 0
    }
}*/
