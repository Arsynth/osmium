//
// Created by Artem Sechko on 10.11.2021.
//

import Foundation
import ModelIO
import Metal

public class OSMMaterial {
    public let device: MTLDevice
    public var shader: OSMShader?
    private(set) var uniforms = MaterialUniforms()

    private(set) public var properties: [OSMMaterialSemantic: OSMMaterialProperty] = [:]

    /// Init with all known properties
    public init(material: MDLMaterial, device: MTLDevice) {
        self.device = device
        for mdlSemantic in MDLMaterialSemantic.knownCases {
            if let semantic = OSMMaterialSemantic(mdlSemantic: mdlSemantic),
                let mdlProperty = material.property(with: mdlSemantic) {
                let property = OSMMaterialProperty(
                        value: OSMMaterialPropertyValue(mdlProperty: mdlProperty, device: device),
                        functionConstantIndex: semantic.defaultFunctionConstantIndex
                )
                properties[semantic] = property
            }
        }
        uniforms.applyValidValues(fromProperties: properties)
    }

    public init(device: MTLDevice) {
        self.device = device
    }
}

public extension OSMMaterial {
    var constantBoundProperties: [OSMMaterialSemantic: OSMMaterialProperty] {
        var result: [OSMMaterialSemantic: OSMMaterialProperty] = [:]
        for (semantic, property) in properties {
            if property.functionConstantIndex != nil {
                result[semantic] = property
            }
        }
        return result
    }

    func setProperty(_ property: OSMMaterialProperty, forSemantic semantic: OSMMaterialSemantic) {
        properties[semantic] = property
        uniforms.applyValidValue(fromProperty: property, semantic: semantic)
    }

    func removeProperty(forSemantic semantic: OSMMaterialSemantic) {
        properties.removeValue(forKey: semantic)
    }

    func removeAllProperties() {
        properties.removeAll()
    }
}

public extension OSMMaterial {
    func setBuffer(_ buffer: MTLBuffer,
                   offset: Int = 0,
                   semantic: OSMMaterialSemantic,
                   functionConstantIndex: Int? = nil) {
        setProperty(
                OSMMaterialProperty(
                        value: .buffer(value: buffer, offset: offset),
                        functionConstantIndex: functionConstantIndex ?? semantic.defaultFunctionConstantIndex
                ),
                forSemantic: semantic
        )
    }

    func setBytes(_ bytes: Data, semantic: OSMMaterialSemantic, functionConstantIndex: Int? = nil) {
        setProperty(
                OSMMaterialProperty(
                        value: .bytes(value: bytes),
                        functionConstantIndex: functionConstantIndex ?? semantic.defaultFunctionConstantIndex
                ),
                forSemantic: semantic
        )
    }

    func setTexture(_ texture: MTLTexture,
                    samplerDescriptor: MTLSamplerDescriptor? = nil,
                    semantic: OSMMaterialSemantic,
                    functionConstantIndex: Int? = nil) {
        setProperty(
                OSMMaterialProperty(
                        value: .texture(value: texture, samplerDescriptor: samplerDescriptor),
                        functionConstantIndex: functionConstantIndex ?? semantic.defaultFunctionConstantIndex
                ),
                forSemantic: semantic
        )
    }

    func setColor(_ color: CGColor, semantic: OSMMaterialSemantic, functionConstantIndex: Int? = nil) {
        setProperty(
                OSMMaterialProperty(
                        value: .color(value: color),
                        functionConstantIndex: functionConstantIndex ?? semantic.defaultFunctionConstantIndex
                ),
                forSemantic: semantic
        )
    }

    func setSamplerDescriptor(_ descriptor: MTLSamplerDescriptor,
                              semantic: OSMMaterialSemantic,
                              functionConstantIndex: Int? = nil) {
        setProperty(
                OSMMaterialProperty(
                        value: .samplerDescriptor(value: descriptor),
                        functionConstantIndex: functionConstantIndex ?? semantic.defaultFunctionConstantIndex
                ),
                forSemantic: semantic
        )
    }

    func setFloatValue(_ floatValue: Float,
                              semantic: OSMMaterialSemantic,
                              functionConstantIndex: Int? = nil) {
        setProperty(
                OSMMaterialProperty(
                        value: .float(value: floatValue),
                        functionConstantIndex: functionConstantIndex ?? semantic.defaultFunctionConstantIndex
                ),
                forSemantic: semantic
        )
    }

    func setFloat2Value(_ float2Value: SIMD2<Float>,
                              semantic: OSMMaterialSemantic,
                              functionConstantIndex: Int? = nil) {
        setProperty(
                OSMMaterialProperty(
                        value: .float2(value: float2Value),
                        functionConstantIndex: functionConstantIndex ?? semantic.defaultFunctionConstantIndex
                ),
                forSemantic: semantic
        )
    }

    func setFloat3Value(_ float3Value: SIMD3<Float>,
                              semantic: OSMMaterialSemantic,
                              functionConstantIndex: Int? = nil) {
        setProperty(
                OSMMaterialProperty(
                        value: .float3(value: float3Value),
                        functionConstantIndex: functionConstantIndex ?? semantic.defaultFunctionConstantIndex
                ),
                forSemantic: semantic
        )
    }

    func setFloat4Value(_ float4Value: SIMD4<Float>,
                              semantic: OSMMaterialSemantic,
                              functionConstantIndex: Int? = nil) {
        setProperty(
                OSMMaterialProperty(
                        value: .float4(value: float4Value),
                        functionConstantIndex: functionConstantIndex ?? semantic.defaultFunctionConstantIndex
                ),
                forSemantic: semantic
        )
    }

    func setFloat3x3Value(_ float3x3Value: float3x3,
                              semantic: OSMMaterialSemantic,
                              functionConstantIndex: Int? = nil) {
        setProperty(
                OSMMaterialProperty(
                        value: .float3x3(value: float3x3Value),
                        functionConstantIndex: functionConstantIndex ?? semantic.defaultFunctionConstantIndex
                ),
                forSemantic: semantic
        )
    }

    func setFloat4x4Value(_ float4x4Value: float4x4,
                              semantic: OSMMaterialSemantic,
                              functionConstantIndex: Int? = nil) {
        setProperty(
                OSMMaterialProperty(
                        value: .float4x4(value: float4x4Value),
                        functionConstantIndex: functionConstantIndex ?? semantic.defaultFunctionConstantIndex
                ),
                forSemantic: semantic
        )
    }

    func setTiling(_ tiling: SIMD2<Float>) {
        setProperty(
                OSMMaterialProperty(
                        value: .float2(value: tiling),
                        functionConstantIndex: nil
                ),
                forSemantic: .tiling
        )
    }
}
