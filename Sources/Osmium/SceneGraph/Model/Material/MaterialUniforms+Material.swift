//
//  File.swift
//  
//
//  Created by Artem Sechko on 11.03.2022.
//

import Foundation
import simd

public extension MaterialUniforms {
    mutating func applyValidValues(fromProperties properties: [OSMMaterialSemantic: OSMMaterialProperty]) {
        for record in properties {
            applyValidValue(fromProperty: record.value, semantic: record.key)
        }
    }

    mutating func applyValidValue(fromProperty property: OSMMaterialProperty, semantic: OSMMaterialSemantic) {
        switch semantic {
        case .baseColor: property.evaluateFloat3 { baseColor = $0 }
        case .subsurface: break
        case .metallic: property.evaluateFloat { metallic = $0 }
        case .specular: property.evaluateFloat3 { specular = $0 }
        case .specularExponent: property.evaluateFloat { specularExponent = $0 }
        case .specularTint: break
        case .roughness: property.evaluateFloat { roughness = $0 }
        case .anisotropic: break
        case .anisotropicRotation: break
        case .sheen: break
        case .sheenTint: break
        case .clearcoat: break
        case .clearcoatGloss: break
        case .emission: break
        case .bump: break
        case .opacity: property.evaluateFloat { opacity = $0 }
        case .interfaceIndexOfRefraction: break
        case .materialIndexOfRefraction: break
        case .objectSpaceNormal: break
        case .tangentSpaceNormal: break
        case .displacement: break
        case .displacementScale: break
        case .ambientOcclusion: property.evaluateFloat3 { ambientOcclusion = $0 }
        case .ambientOcclusionScale: break
        case .reflective: property.evaluateFloat3 { reflective = $0 }
        case .tiling: property.evaluateFloat2 { tiling = $0 }
        case .none: break
        case .custom(_): break
        }
    }
}

private extension OSMMaterialProperty {
    func evaluateFloat(block: (Float) -> Void) {
        switch value {
        case let .float(result): block(result)
        default: break
        }
    }

    func evaluateFloat2(block: (SIMD2<Float>) -> Void) {
        switch value {
        case let .float2(result): block(result)
        default: break
        }
    }

    func evaluateFloat3(block: (SIMD3<Float>) -> Void) {
        switch value {
        case let .float3(result): block(result)
        default: break
        }
    }
}
