//
// Created by Artem Sechko on 09.12.2021.
//

import Foundation
import Metal
/*
class NoTileOITRenderData {
    let metalConfig: MetalConfig
    let renderTargetSize: SIMD2<Int32>

    let fragCounterBuffer: MTLBuffer

    let headsCount: Int
    let headsBufferSize: Int
    let headsBuffer: MTLBuffer

    let fragListBufferSize: Int
    let fragListBuffer: MTLBuffer

    init(withMetalConfig metalConfig: MetalConfig, renderTargetSize: SIMD2<Int32>) {
        self.metalConfig = metalConfig
        self.renderTargetSize = renderTargetSize

        let device = metalConfig.device
        let pixelCount = Int(renderTargetSize.x * renderTargetSize.y)

        fragCounterBuffer = device.makeBuffer(length: MemoryLayout<UInt32>.stride)!
        fragCounterBuffer.label = "fragCounter"

        let headsBufferSize = pixelCount * MemoryLayout<UInt32>.stride
        headsCount = pixelCount
        self.headsBufferSize = headsBufferSize
        headsBuffer = device.makeBuffer(length: headsBufferSize)!
        headsBuffer.label = "heads"

        let fragmentsCount = pixelCount * Int(metalConfig.maxOitLayersCount)
        let fragListBufferSize = fragmentsCount * MemoryLayout<ListItem>.stride
        self.fragListBufferSize = fragListBufferSize
        fragListBuffer = device.makeBuffer(length: fragListBufferSize)!
        fragListBuffer.label = "fragList"
    }
}

class NoTileOITData {
    static let quadVertices = [
        OITComposeVertex(position: [1.0, -1.0]),
        OITComposeVertex(position: [-1.0, 1.0]),
        OITComposeVertex(position: [-1.0, -1.0]),
        OITComposeVertex(position: [1.0, 1.0])
    ]
    static let quadIndices: [UInt16] = [0, 1, 2, 0, 3, 1]

    let metalConfig: MetalConfig

    let quadVertexBuffer: MTLBuffer
    let quadIndexBuffer: MTLBuffer

    private(set) var renderTargetSize: SIMD2<Int32> = .zero
    private(set) var renderData: NoTileOITRenderData?

    init(withMetalConfig metalConfig: MetalConfig) {
        self.metalConfig = metalConfig

        var quadVertices = Self.quadVertices
        quadVertexBuffer = metalConfig.device.makeBuffer(
                bytes: &quadVertices,
                length: MemoryLayout<OITComposeVertex>.stride * Self.quadVertices.count
        )!
        quadVertexBuffer.label = "compositionQuad"

        var quadIndices = Self.quadIndices
        quadIndexBuffer = metalConfig.device.makeBuffer(
                bytes: &quadIndices,
                length: MemoryLayout<UInt16>.stride * quadIndices.count
        )!
    }

    func reloadWithNewTargetSize(_ newTargetSize: SIMD2<Int32>) {
        guard renderTargetSize != newTargetSize else { return }

        renderTargetSize = newTargetSize
        guard renderTargetSize.x > 0 && renderTargetSize.y > 0 else {
            renderData = nil
            return
        }

        renderData = NoTileOITRenderData(withMetalConfig: metalConfig, renderTargetSize: renderTargetSize)
    }
}
 */
