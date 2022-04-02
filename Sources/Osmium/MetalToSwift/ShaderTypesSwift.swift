//
//  File.swift
//  
//
//  Created by Artem Sechko on 11.01.2022.
//

import Foundation
import simd

public struct BBox {
    var minPosition: float3
    var maxPosition: float3
}

public struct ModelUniforms {
    var modelMatrix: float4x4
    var normalMatrix: float3x3
    var position: float3
    var bBox: BBox
}

public struct ViewInfo {
    var cameraPosition: float3
    var viewMatrix: float4x4
    var projectionMatrix: float4x4
    var viewProjectionMatrix: float4x4
    var skyboxMatrix: float4x4

    public init(cameraPosition: float3, viewMatrix: float4x4, projectionMatrix: float4x4) {
        self.cameraPosition = cameraPosition
        self.viewMatrix = viewMatrix
        self.projectionMatrix = projectionMatrix
        viewProjectionMatrix = projectionMatrix * viewMatrix
        var skyboxViewMatrix = viewMatrix
        skyboxViewMatrix.columns.3 = [0.0, 0.0, 0.0, 1.0]
        skyboxMatrix = projectionMatrix * skyboxViewMatrix
    }
}

public enum LightType: UInt32 {
    case unused = 0
    case sun = 1
    case spot = 2
    case point = 3
    case ambient = 4
}

public struct LightUniforms {
    var position: float3 = [0, 0, 0]
    var color: float3 = [0, 0, 0]
    var specularColor: float3 = [0, 0, 0]
    var intensity: Float = 0
    var attenuation: float3 = [0, 0, 0]
    var type: UInt32 = LightType.unused.rawValue
    var coneAngle: Float = 0
    var coneDirection: float3 = [0, 0, 0]
    var coneAttenuation: Float = 0
}

public struct SceneUniforms {
    var viewInfo: ViewInfo
    var lightCount: UInt32
}

extension SceneUniforms {
    func with(viewInfo: ViewInfo) -> SceneUniforms {
        SceneUniforms(viewInfo: viewInfo, lightCount: lightCount)
    }
}

public enum AttributeIndex: Int32 {
    case position = 0
    case normal = 1
    case uv = 2
    case tangent = 3
    case bitangent = 4
    case color = 5
    case joints = 6
    case weights = 7
}

public enum BufferIndex: Int32 {
    case vertices = 0
    case tangent = 1
    case bitangent = 2

    case modelUniforms = 3
    case lights = 5
    case sceneUniforms = 7
//    case renderPassUniforms = 8
    case materials = 9
//    case instances = 10
//    case skybox = 11
//    case skyboxDiffuse = 12
//    case brdfLut = 13
//    case fragmentsCounter = 14
//    case fragmentHeads = 15
//    case listItems = 16
}

public struct MaterialUniforms {
    public var baseColor: float3 = float3(repeating: 0.5)
    public var specular: float3 = float3(repeating: 1.0)
    public var roughness: Float = 0.0
    public var metallic: Float = 0.0
    public var ambientOcclusion: float3 = float3(repeating: 1.0)
    public var specularExponent: Float = 32.0
    public var opacity: Float = 1.0
    public var reflective: float3 = float3(repeating: 1.0)

    public var tiling: float2 = float2(repeating: 1.0)
}
