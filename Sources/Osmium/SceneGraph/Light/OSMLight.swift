//
// Created by Artem Sechko on 31.10.2021.
//

import Foundation
import simd

/*
 vector_float3 color;
    vector_float3 specularColor;
    float intensity;
    /// Howto - https://developer.valvesoftware.com/wiki/Constant-Linear-Quadratic_Falloff
    /// Representing constant, linear and quadratic falloff as x, y, z accordingly
    vector_float3 attenuation;
    LightType type;
    float coneAngle;
    vector_float3 coneDirection;
    float coneAttenuation;
 */

public protocol OSMLight {
    var color: float3 { get }
    func uniforms(withTransform transform: float4x4) -> LightUniforms
}

public struct AmbientLight: OSMLight {
    public var color: float3 = [1.0, 1.0, 1.0]
    public var intensity: Float = 1.0

    public init(color: float3, intensity: Float) {
        self.color = color
        self.intensity = intensity
    }

    public func uniforms(withTransform transform: float4x4) -> LightUniforms {
        var result = LightUniforms()
        result.type = LightType.ambient.rawValue

        result.position = float3.zeroPoint(withTransform: transform)
        result.color = color
        result.intensity = intensity
        return result
    }
}

public struct Sunlight: OSMLight {
    public var color: float3 = [1.0, 1.0, 1.0]
    public var intensity: Float = 1.0

    public init(color: float3, intensity: Float) {
        self.color = color
        self.intensity = intensity
    }

    public func uniforms(withTransform transform: float4x4) -> LightUniforms {
        var result = LightUniforms()
        result.type = LightType.sun.rawValue

        result.position = float3.zeroPoint(withTransform: transform)
        result.color = color
        result.specularColor = result.color
        result.intensity = intensity
        return result
    }
}

public struct Pointlight: OSMLight {
    public var color: float3 = [1.0, 1.0, 1.0]
    public var attenuation: float3 = [0.0, 0.0, 0.0]

    public init(color: float3, attenuation: float3) {
        self.color = color
        self.attenuation = attenuation
    }

    public func uniforms(withTransform transform: float4x4) -> LightUniforms {
        var result = LightUniforms()
        result.type = LightType.point.rawValue

        result.position = float3.zeroPoint(withTransform: transform)
        result.color = color
        result.specularColor = result.color
        result.attenuation = attenuation
        return result
    }
}
