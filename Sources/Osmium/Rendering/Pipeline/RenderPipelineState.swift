//
// Created by Artem Sechko on 13.03.2022.
//

import Foundation
import Metal

struct BuiltinArgumentNames {
    static let sceneUniforms = "sceneUniforms"
    static let modelUniforms = "modelUniforms"
    static let material = "material"
    static let lights = "lights"
}

struct FunctionConstant: Hashable {
    let index: Int
    let flag: Bool

    func setToValues(_ values: MTLFunctionConstantValues) {
        var flag = flag
        values.setConstantValue(&flag, type: .bool, index: index)
    }
}

enum ArgumentType: Equatable {
    case buffer
    case texture
    case sampler
}

extension MTLArgumentType {
    /// Returns nil for unsupported type
    var osmArgumentType: ArgumentType? {
        switch self {
        case .buffer: return .buffer
        case .texture: return .texture
        case .sampler: return .sampler
        default: return nil
        }
    }
}

struct Argument: Equatable {
    let name: String
    let index: Int
    let type: ArgumentType
    let isActive: Bool

    init?(mtlArgument: MTLArgument) {
        guard let type = mtlArgument.type.osmArgumentType else {
            print("Warning: unsupported type of MTLArgument(\(mtlArgument.type)). Will be ignored")
            return nil
        }
        name = mtlArgument.name
        self.type = type
        index = mtlArgument.index
        isActive = mtlArgument.isActive
    }
}

struct FunctionHeader {
    let name: String
    let arguments: [Argument]

    init(name: String, arguments: [MTLArgument]) {
        self.name = name
        self.arguments = arguments.compactMap {
            Argument(mtlArgument: $0)
        }
    }
}

struct PipelineStateReflection {
    let vertexHeader: FunctionHeader?
    let fragmentHeader: FunctionHeader?

    init(vertexFunctionName: String?, fragmentFunctionName: String?, mtlReflection: MTLRenderPipelineReflection) {
        if let vertexFunctionName = vertexFunctionName,
           let vertexArguments = mtlReflection.vertexArguments {
            vertexHeader = FunctionHeader(name: vertexFunctionName, arguments: vertexArguments)
        } else {
            vertexHeader = nil
        }
        if let fragmentFunctionName = fragmentFunctionName,
           let fragmentArguments = mtlReflection.fragmentArguments {
            fragmentHeader = FunctionHeader(name: fragmentFunctionName, arguments: fragmentArguments)
        } else {
            fragmentHeader = nil
        }
    }
}

struct RenderPipelineState {
    let pso: MTLRenderPipelineState
    let reflection: PipelineStateReflection

    let depthStencilDescriptor: MTLDepthStencilDescriptor
    let depthStencilState: MTLDepthStencilState

    init(pso: MTLRenderPipelineState,
         vertexFunctionName: String?,
         fragmentFunctionName: String?,
         mtlReflection: MTLRenderPipelineReflection,
         depthStencilDescriptor: MTLDepthStencilDescriptor,
         depthStencilState: MTLDepthStencilState) {
        self.pso = pso
        reflection = PipelineStateReflection(
                vertexFunctionName: vertexFunctionName,
                fragmentFunctionName: fragmentFunctionName,
                mtlReflection: mtlReflection
        )

        self.depthStencilDescriptor = depthStencilDescriptor
        self.depthStencilState = depthStencilState
    }
}

extension Argument {
    var counterpartSamplerName: String {
        name + "_S"
    }
}

extension Array where Array.Element == Argument {
    func argument(named name: String, withType type: ArgumentType) -> Argument? {
        filter {
            $0.name == name && $0.type == type
        }.first
    }
}
