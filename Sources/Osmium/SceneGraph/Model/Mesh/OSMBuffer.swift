//
// Created by Artem Sechko on 19.03.2022.
//

import Foundation
import Metal
import MetalKit

public struct OSMBuffer {
    public var mtlBuffer: MTLBuffer
    public var offset: Int
    public var allocationLength: Int

    public init(mtlBuffer: MTLBuffer, offset: Int, allocationLength: Int) {
        self.mtlBuffer = mtlBuffer
        self.offset = offset
        self.allocationLength = allocationLength
    }

    public init(mtkBuffer: MTKMeshBuffer) {
        mtlBuffer = mtkBuffer.buffer
        offset = mtkBuffer.offset
        allocationLength = mtkBuffer.length
    }
}
