//
// Created by Artem Sechko on 31.03.2022.
//

import Foundation
import ModelIO
import Metal

let kBaseColorSemantic = "baseColor"
let kSubsurfaceSemantic = "subsurface"
let kMetallicSemantic = "metallic"
let kSpecularSemantic = "specular"
let kSpecularExponentSemantic = "specularExponent"
let kSpecularTintSemantic = "specularTint"
let kRoughnessSemantic = "roughness"
let kAnisotropicSemantic = "anisotropic"
let kAnisotropicRotationSemantic = "anisotropicRotation"
let kSheenSemantic = "sheen"
let kSheenTintSemantic = "sheenTint"
let kClearoatSemantic = "clearcoat"
let kClearcoatGlossSemantic = "clearcoatGloss"
let kEmissionSemantic = "emission"
let kBumpSemantic = "bump"
let kOpacitySemantic = "opacity"
let kInterfaceIORSemantic = "interfaceIndexOfRefraction"
let kMaterialIORSemantic = "materialIndexOfRefraction"
let kObjectSpaceNormalSemantic = "objectSpaceNormal"
let kTangentSpaceNormalSemantic = "tangentSpaceNormal"
let kDisplacementSemantic = "displacement"
let kDisplacementScaleSemantic = "displacementScale"
let kAmbientOcclusionSemantic = "ambientOcclusion"
let kAmbientOcclusionScaleSemantic = "ambientOcclusionScale"
let kReflectiveSemantic = "reflective"
let kTilingSemantic = "tiling"
let kNoneSemantic = "none"

/// Semantic name will be mapped into shader argument name and automatically associated with index
public enum OSMMaterialSemantic: Hashable {
    case baseColor
    case subsurface // Unused yet
    case metallic
    case specular
    case specularExponent
    case specularTint // Unused yet
    case roughness
    case anisotropic // Unused yet
    case anisotropicRotation // Unused yet
    case sheen // Unused yet
    case sheenTint // Unused yet
    case clearcoat // Unused yet
    case clearcoatGloss // Unused yet
    case emission // Unused yet
    case bump // Unused yet
    case opacity
    case interfaceIndexOfRefraction // Unused yet
    case materialIndexOfRefraction // Unused yet
    case objectSpaceNormal // Unused yet
    case tangentSpaceNormal // Unused yet
    case displacement // Unused yet
    case displacementScale // Unused yet
    case ambientOcclusion
    case ambientOcclusionScale // Unused yet
    case reflective
    case tiling
    case none
    /// User-defined semantic
    case custom(String)
}

extension OSMMaterialSemantic: RawRepresentable {
    public typealias RawValue = String

    public init?(rawValue: RawValue) {
        switch rawValue {
        case kBaseColorSemantic: self = .baseColor
        case kSubsurfaceSemantic: self = .subsurface
        case kMetallicSemantic: self = .metallic
        case kSpecularSemantic: self = .specular
        case kSpecularExponentSemantic: self = .specularExponent
        case kSpecularTintSemantic: self = .specularTint
        case kRoughnessSemantic: self = .roughness
        case kAnisotropicSemantic: self = .anisotropic
        case kAnisotropicRotationSemantic: self = .anisotropicRotation
        case kSheenSemantic: self = .sheen
        case kSheenTintSemantic: self = .sheenTint
        case kClearoatSemantic: self = .clearcoat
        case kClearcoatGlossSemantic: self = .clearcoatGloss
        case kEmissionSemantic: self = .emission
        case kBumpSemantic: self = .bump
        case kOpacitySemantic: self = .opacity
        case kInterfaceIORSemantic: self = .interfaceIndexOfRefraction
        case kMaterialIORSemantic: self = .materialIndexOfRefraction
        case kObjectSpaceNormalSemantic: self = .objectSpaceNormal
        case kTangentSpaceNormalSemantic: self = .tangentSpaceNormal
        case kDisplacementSemantic: self = .displacement
        case kDisplacementScaleSemantic: self = .displacementScale
        case kAmbientOcclusionSemantic: self = .ambientOcclusion
        case kAmbientOcclusionScaleSemantic: self = .ambientOcclusionScale
        case kReflectiveSemantic: self = .reflective
        case kTilingSemantic: self = .tiling
        case kNoneSemantic: self = .none
        default: self = .custom(rawValue)
        }
    }

    public var rawValue: RawValue {
        switch self {
        case .baseColor: return kBaseColorSemantic
        case .subsurface: return kSubsurfaceSemantic
        case .metallic: return kMetallicSemantic
        case .specular: return kSpecularSemantic
        case .specularExponent: return kSpecularExponentSemantic
        case .specularTint: return kSpecularTintSemantic
        case .roughness: return kRoughnessSemantic
        case .anisotropic: return kAnisotropicSemantic
        case .anisotropicRotation: return kAnisotropicRotationSemantic
        case .sheen: return kSheenSemantic
        case .sheenTint: return kSheenTintSemantic
        case .clearcoat: return kClearoatSemantic
        case .clearcoatGloss: return kClearcoatGlossSemantic
        case .emission: return kEmissionSemantic
        case .bump: return kBumpSemantic
        case .opacity: return kOpacitySemantic
        case .interfaceIndexOfRefraction: return kInterfaceIORSemantic
        case .materialIndexOfRefraction: return kMaterialIORSemantic
        case .objectSpaceNormal: return kObjectSpaceNormalSemantic
        case .tangentSpaceNormal: return kTangentSpaceNormalSemantic
        case .displacement: return kDisplacementSemantic
        case .displacementScale: return kDisplacementScaleSemantic
        case .ambientOcclusion: return kAmbientOcclusionSemantic
        case .ambientOcclusionScale: return kAmbientOcclusionScaleSemantic
        case .reflective: return kReflectiveSemantic
        case .tiling: return kTilingSemantic
        case .none: return kNoneSemantic
        case let .custom(text): return text
        }
    }
}

extension OSMMaterialSemantic {
    init?(mdlSemantic: MDLMaterialSemantic) {
        switch mdlSemantic {
        case .baseColor: self = .baseColor
        case .subsurface: self = .subsurface
        case .metallic: self = .metallic
        case .specular: self = .specular
        case .specularExponent: self = .specularExponent
        case .specularTint: self = .specularTint
        case .roughness: self = .roughness
        case .anisotropic: self = .anisotropic
        case .anisotropicRotation: self = .anisotropicRotation
        case .sheen: self = .sheen
        case .sheenTint: self = .sheenTint
        case .clearcoat: self = .clearcoat
        case .clearcoatGloss: self = .clearcoatGloss
        case .emission: self = .emission
        case .bump: self = .bump
        case .opacity: self = .opacity
        case .interfaceIndexOfRefraction: self = .interfaceIndexOfRefraction
        case .materialIndexOfRefraction: self = .materialIndexOfRefraction
        case .objectSpaceNormal: self = .objectSpaceNormal
        case .tangentSpaceNormal: self = .tangentSpaceNormal
        case .displacement: self = .displacement
        case .displacementScale: self = .displacementScale
        case .ambientOcclusion: self = .ambientOcclusion
        case .ambientOcclusionScale: self = .ambientOcclusionScale
        case .none: self = .none
        case .userDefined: self = .custom("userDefined")
        @unknown default:
            self = .custom("unknown")
        }
    }
}

extension OSMMaterialSemantic {
    var defaultFunctionConstantIndex: Int? {
        switch self {
        case .baseColor: return 0
        case .bump: return 1 // Normal texture
        case .roughness: return 2
        case .metallic: return 3
        case .ambientOcclusion: return 4
        case .reflective: return 6
        default: return nil
        }
    }
}

extension MDLMaterialSemantic {
    static var knownCases: [MDLMaterialSemantic] {
        [
            .baseColor,
            .subsurface,
            .metallic,
            .specular,
            .specularExponent,
            .specularTint,
            .roughness,
            .anisotropic,
            .anisotropicRotation,
            .sheen,
            .sheenTint,
            .clearcoat,
            .clearcoatGloss,
            .emission,
            .bump,
            .opacity,
            .interfaceIndexOfRefraction,
            .materialIndexOfRefraction,
            .objectSpaceNormal,
            .tangentSpaceNormal,
            .displacement,
            .displacementScale,
            .ambientOcclusion,
            .ambientOcclusionScale,
            .userDefined,
            .none,
        ]
    }
}
