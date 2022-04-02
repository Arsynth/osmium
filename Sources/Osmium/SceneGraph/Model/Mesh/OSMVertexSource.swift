//
// Created by Artem Sechko on 16.03.2022.
//

import Foundation
import Metal
import ModelIO
import MetalKit

public struct OSMVertexSource {
    public var vertexBuffers: [OSMBuffer]
    public var vertexDescriptor: OSMVertexDescriptor
    public var vertexCount: Int

    public init(vertexBuffers: [OSMBuffer], vertexDescriptor: OSMVertexDescriptor, vertexCount: Int) {
        self.vertexBuffers = vertexBuffers
        self.vertexDescriptor = vertexDescriptor
        self.vertexCount = vertexCount
    }

    public init(mtkMesh: MTKMesh) {
        vertexBuffers = mtkMesh.vertexBuffers.map { OSMBuffer(mtkBuffer: $0) }
        vertexDescriptor = OSMVertexDescriptor(mdlDescriptor: mtkMesh.vertexDescriptor)
        vertexCount = mtkMesh.vertexCount
    }
}
