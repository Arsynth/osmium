//
// Created by Artem Sechko on 28.03.2021.
//

import ModelIO

extension MDLVertexDescriptor {
    private(set) static var defaultVertexDescriptor: MDLVertexDescriptor = {
        let vertexDescriptor = MDLVertexDescriptor()

        var offset = 0
        // Position attribute
        vertexDescriptor.attributes[Int(AttributeIndex.position.rawValue)] = MDLVertexAttribute(
                name: MDLVertexAttributePosition,
                format: .float3,
                offset: offset,
                bufferIndex: Int(BufferIndex.vertices.rawValue)
        )
        offset += MemoryLayout<float3>.stride

        // Normal attribute
        vertexDescriptor.attributes[Int(AttributeIndex.normal.rawValue)] = MDLVertexAttribute(
                name: MDLVertexAttributeNormal,
                format: .float3,
                offset: offset,
                bufferIndex: Int(BufferIndex.vertices.rawValue)
        )
        offset += MemoryLayout<float3>.stride

        // UV
        vertexDescriptor.attributes[Int(AttributeIndex.uv.rawValue)] = MDLVertexAttribute(
                name: MDLVertexAttributeTextureCoordinate,
                format: .float2,
                offset: offset,
                bufferIndex: Int(BufferIndex.vertices.rawValue)
        )
        offset += MemoryLayout<float2>.stride

        // Color attribute
        vertexDescriptor.attributes[Int(AttributeIndex.color.rawValue)] = MDLVertexAttribute(
                name: MDLVertexAttributeColor,
                format: .float3,
                offset: offset,
                bufferIndex: Int(BufferIndex.vertices.rawValue)
        )
        offset += MemoryLayout<float3>.stride

        /// TBD: Joints!

        // Tangent
        vertexDescriptor.attributes[Int(AttributeIndex.tangent.rawValue)] = MDLVertexAttribute(
                name: MDLVertexAttributeTangent,
                format: .float3,
                offset: 0,
                bufferIndex: Int(BufferIndex.tangent.rawValue)
        )

        // Bitangent
        vertexDescriptor.attributes[Int(AttributeIndex.bitangent.rawValue)] = MDLVertexAttribute(
                name: MDLVertexAttributeBitangent,
                format: .float3,
                offset: 0,
                bufferIndex: Int(BufferIndex.bitangent.rawValue)
        )

        vertexDescriptor.layouts[Int(BufferIndex.vertices.rawValue)] = MDLVertexBufferLayout(stride: offset)
        vertexDescriptor.layouts[Int(BufferIndex.tangent.rawValue)] = MDLVertexBufferLayout(stride: MemoryLayout<float3>.stride)
        vertexDescriptor.layouts[Int(BufferIndex.bitangent.rawValue)] = MDLVertexBufferLayout(stride: MemoryLayout<float3>.stride)
        return vertexDescriptor
    }()
}
