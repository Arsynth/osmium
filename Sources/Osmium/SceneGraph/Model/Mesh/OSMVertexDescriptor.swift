//
// Created by Artem Sechko on 20.03.2022.
//

import Foundation
import Metal
import ModelIO
import MetalKit

public extension OSMVertexAttribute.Semantic {
    init?(mdlName: String) {
        switch mdlName {
        case MDLVertexAttributeAnisotropy: self = .anisotropy
        case MDLVertexAttributeBinormal: self = .binormal
        case MDLVertexAttributeTangent: self = .tangent
        case MDLVertexAttributeBitangent: self = .bitangent
        case MDLVertexAttributeColor: self = .color
        case MDLVertexAttributeEdgeCrease: self = .edgeCrease
        case MDLVertexAttributeJointIndices: self = .boneIndices
        case MDLVertexAttributeJointWeights: self = .boneWeights
        case MDLVertexAttributeNormal: self = .normal
        case MDLVertexAttributeOcclusionValue: self = .ambientOcclusion
        case MDLVertexAttributePosition: self = .position
        case MDLVertexAttributeShadingBasisU: self = .shadingBasisU
        case MDLVertexAttributeShadingBasisV: self = .shadingBasisV
        case MDLVertexAttributeSubdivisionStencil: self = .subdivisionStencil
        case MDLVertexAttributeTextureCoordinate: self = .texcoord
        default: self = .userDefined(mdlName)
        }
    }
}

public struct OSMVertexAttribute {
    public enum Semantic {
        case position
        case normal
        case color
        case texcoord
        case binormal
        case tangent
        case bitangent
        case vertexCrease
        case edgeCrease
        case boneWeights
        case boneIndices
        case ambientOcclusion
        case shadingBasisU
        case shadingBasisV
        case subdivisionStencil
        case anisotropy
        case userDefined(String)
    }

    public var semantic: Semantic
    public var format: MTLVertexFormat
    /// Start offset for attribute
    public var offset: Int
    public var bufferIndex: Int
    public var time: TimeInterval

    public init(semantic: Semantic,
                format: MTLVertexFormat,
                offset: Int,
                bufferIndex: Int,
                time: TimeInterval) {
        self.semantic = semantic
        self.format = format
        self.offset = offset
        self.bufferIndex = bufferIndex
        self.time = time
    }

    public init(mdlAttribute: MDLVertexAttribute) {
        semantic = Semantic(mdlName: mdlAttribute.name)!
        format = MTKMetalVertexFormatFromModelIO(mdlAttribute.format)
        offset = mdlAttribute.offset
        bufferIndex = mdlAttribute.bufferIndex
        time = mdlAttribute.time
    }
}

public struct OSMVertexBufferLayout {
    /// Stride for each vertex
    public var stride: Int

    public init(stride: Int) {
        self.stride = stride
    }

    public init(mdlLayout: MDLVertexBufferLayout) {
        stride = mdlLayout.stride
    }
}

public struct OSMVertexDescriptor {
    public var attributes: [OSMVertexAttribute]
    public var layouts: [OSMVertexBufferLayout]

    public init(attributes: [OSMVertexAttribute], layouts: [OSMVertexBufferLayout]) {
        self.attributes = attributes
        self.layouts = layouts
    }

    public init(mdlDescriptor: MDLVertexDescriptor) {
        attributes = mdlDescriptor.attributes.map { OSMVertexAttribute(mdlAttribute: ($0 as! MDLVertexAttribute)) }
        layouts = mdlDescriptor.layouts.map { OSMVertexBufferLayout(mdlLayout: ($0 as! MDLVertexBufferLayout)) }
    }
}

public extension OSMVertexDescriptor {
    func makeMTLDescriptor() -> MTLVertexDescriptor {
        let result = MTLVertexDescriptor()
        for (idx, attribute) in attributes.enumerated() {
            let mtlAttribute = MTLVertexAttributeDescriptor()
            mtlAttribute.format = attribute.format
            mtlAttribute.offset = attribute.offset
            mtlAttribute.bufferIndex = attribute.bufferIndex
            result.attributes[idx] = mtlAttribute
        }

        for (idx, layout) in layouts.enumerated() {
            let mtlLayout = MTLVertexBufferLayoutDescriptor()
            mtlLayout.stride = layout.stride
            result.layouts[idx] = mtlLayout
        }

        return result
    }
}
