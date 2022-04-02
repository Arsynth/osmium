//
// Created by Artem Sechko on 27.03.2021.
//

import MetalKit
import ModelIO

public class OSMSubmesh {
    let name: String

    public let primitiveType: MTLPrimitiveType
    public let indexType: MTLIndexType
    public let indexCount: Int
    public let indexBuffer: MTLBuffer
    public let indexBufferOffset: Int

    init(mdlSubmesh: MDLSubmesh, mtkSubmesh: MTKSubmesh) {
        name = mdlSubmesh.name
        primitiveType = mtkSubmesh.primitiveType
        indexType = mtkSubmesh.indexType
        indexCount = mtkSubmesh.indexCount
        indexBuffer = mtkSubmesh.indexBuffer.buffer
        indexBufferOffset = mtkSubmesh.indexBuffer.offset
    }
}
