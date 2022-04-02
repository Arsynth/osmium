//
//  File.swift
//  
//
//  Created by Artem Sechko on 10.03.2022.
//

import Foundation
import MetalKit
import ModelIO
import Metal
import simd

var textureLoaderOptions: [MTKTextureLoader.Option: Any] {
    [
        .origin: MTKTextureLoader.Origin.bottomLeft,
        .SRGB: false,
        .generateMipmaps: NSNumber(booleanLiteral: true)
    ]
}

public enum OSMMaterialPropertyValue {
    case none
    case buffer(value: MTLBuffer, offset: Int)
    case bytes(value: Data)
    case texture(value: MTLTexture, samplerDescriptor: MTLSamplerDescriptor?)
    /// Will interpreted as float4 bytes
    case color(value: CGColor)
    case samplerDescriptor(value: MTLSamplerDescriptor)

    case float(value: Float)
    case float2(value: SIMD2<Float>)
    case float3(value: SIMD3<Float>)
    case float4(value: SIMD4<Float>)
    case float3x3(value: float3x3)
    case float4x4(value: float4x4)
}

public extension OSMMaterialPropertyValue {
    var isBytes: Bool {
        switch self {
        case .bytes, .float, .float2, .float3, .float4, .float3x3, .float4x4, .color: return true
        default: return false
        }
    }

    var isBuffer: Bool {
        switch self {
        case .buffer: return true
        default: return false
        }
    }

    var isTexture: Bool {
        switch self {
        case .texture: return true
        default: return false
        }
    }

    var isSamplerDescriptor: Bool {
        switch self {
        case .samplerDescriptor: return true
        default: return false
        }
    }

    var hasSamplerDescriptor: Bool {
        switch self {
        case .samplerDescriptor: return true
        case let .texture(_, descriptor): return descriptor != nil
        default: return false
        }
    }

    func getBufferWithOffset() -> (MTLBuffer, Int)? {
        switch self {
        case let .buffer(value, offset): return (value, offset)
        default: return nil
        }
    }

    func getBytesData() -> Data? {
        switch self {
        case let .bytes(value): return value
        case let .float(value): return Data(value: value)
        case let .float2(value): return Data(value: value)
        case let .float3(value): return Data(value: value)
        case let .float4(value): return Data(value: value)
        case let .float3x3(value): return Data(value: value)
        case let .float4x4(value): return Data(value: value)
        case let .color(value): return Data(value: value.float4Value)
        default: return nil
        }
    }

    func getTexture() -> MTLTexture? {
        switch self {
        case let .texture(value, _): return value
        default: return nil
        }
    }

    func getColor() -> CGColor? {
        switch self {
        case let .color(value): return value
        default: return nil
        }
    }

    func getSamplerDescriptor() -> MTLSamplerDescriptor? {
        switch self {
        case let .texture(_, descriptor) where descriptor != nil:
            return descriptor
        case let .samplerDescriptor(value): return value
        default: return nil
        }
    }
}

public extension OSMMaterialPropertyValue {
    init(mdlProperty: MDLMaterialProperty, device: MTLDevice) {
        switch mdlProperty.type {
        case .none:
            self = .none
        case .string:
            let filename = mdlProperty.stringValue!
            guard let texture = try? MaterialUtils.loadTexture(imageName: filename, device: device) else {
                self = .none
                return
            }
            self = .texture(
                value: texture,
                samplerDescriptor: mdlProperty.textureSamplerValue?.hardwareFilter?.mtlSampler
            )
        case .URL:
            let url = mdlProperty.urlValue!
            guard let texture = try? MaterialUtils.loadTexture(url: url, device: device) else {
                self = .none
                return
            }
            self = .texture(
                value: texture,
                samplerDescriptor: mdlProperty.textureSamplerValue?.hardwareFilter?.mtlSampler
            )
        case .texture:
            let mdlSampler = mdlProperty.textureSamplerValue!
            let mdlTexture = mdlSampler.texture!
            guard let texture = try? MaterialUtils.loadTexture(texture: mdlTexture, device: device) else {
                self = .none
                return
            }
            self = .texture(
                value: texture,
                samplerDescriptor: mdlProperty.textureSamplerValue?.hardwareFilter?.mtlSampler
            )
        case .color:
            self = .color(
                value: mdlProperty.color ?? CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            )
        case .float:
            self = .float(value: mdlProperty.floatValue)
        case .float2:
            self = .float2(value: mdlProperty.float2Value)
        case .float3:
            self = .float3(value: mdlProperty.float3Value)
        case .float4:
            self = .float4(value: mdlProperty.float4Value)
        case .matrix44:
            self = .float4x4(value: mdlProperty.matrix4x4)
        @unknown default:
            self = .none
        }
    }

    init(cgImage: CGImage, samplerDescriptor: MTLSamplerDescriptor? = nil, device: MTLDevice) {
        guard let texture = try? MaterialUtils.loadTexture(cgImage: cgImage, device: device) else {
            self = .none
            return
        }
        self = .texture(value: texture, samplerDescriptor: samplerDescriptor)
    }
}

extension OSMMaterialPropertyValue {
    var isEmpty: Bool {
        !isNotEmpty
    }
    var isNotEmpty: Bool {
        switch self {
        case .none: return false
        default: return true
        }
    }
}

public struct OSMMaterialProperty {
    public let value: OSMMaterialPropertyValue
    /// Used for function specialization. It should be specified if named argument depends on function constant
    public let functionConstantIndex: Int?

    public init(value: OSMMaterialPropertyValue, functionConstantIndex: Int?) {
        self.value = value
        self.functionConstantIndex = functionConstantIndex
    }
}
