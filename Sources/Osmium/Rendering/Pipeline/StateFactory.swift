//
// Created by Artem Sechko on 11.08.2021.
//

import Foundation
import Metal

public let kDefaultVertexFunctionName = "vertex_main"
public let kOpaqueFragmentFunctionName = "fragment_main"
public let kOITFragmentFunctionName = "fragment_OIT_main"

private extension SubmeshItem {
    var vertexFunctionName: String {
        if let shaderFunc = material.shader?.vertexFunctionName {
            return shaderFunc
        }
        return kDefaultVertexFunctionName
    }

    var fragmentFunctionName: String {
        let isOpaque: Bool
        if let shader = material.shader {
            if let shaderFunc = shader.fragmentFunctionName {
                return shaderFunc
            }
            isOpaque = shader.isOpaque
        } else if opacity < 1.0 {
            isOpaque = false
        } else {
            isOpaque = true
        }
        return isOpaque ? kOpaqueFragmentFunctionName : kOITFragmentFunctionName
    }

    func functionName(forType type: RenderFunctionType) -> String {
        switch type {
        case .vertex: return vertexFunctionName
        case .fragment: return fragmentFunctionName
        }
    }
}

private extension MTLFunction {
    var unsatisfiedConstants: [FunctionConstant] {
        Array(functionConstantsDictionary.values).map { FunctionConstant(index: $0.index, flag: true) }
    }
}

final class StateFactory {
    private let defaultLibrary: MTLLibrary
    private let pipelineColors: [MTLRenderPipelineColorAttachmentDescriptor]
    private let functionCache = FunctionCache.shared

    init(defaultLibrary: MTLLibrary) {
        self.defaultLibrary = defaultLibrary
        pipelineColors = Self.makeDefaultPipelineColors()
    }

    func makePipelineState(forSubmesh submesh: SubmeshItem,
                           vertexDescriptor: OSMVertexDescriptor) -> RenderPipelineState {
        let unspecPipelineDescriptor = getPipelineDescriptor(
                forSubmesh: submesh,
                vertexDescriptor: vertexDescriptor,
                providedVertexConstants: [],
                providedFragmentConstants: []
        )

        let vertexRequired = unspecPipelineDescriptor.vertexFunction?.unsatisfiedConstants ?? []
        let fragmentRequired = unspecPipelineDescriptor.fragmentFunction?.unsatisfiedConstants ?? []

        let specPipelineDescriptor = getPipelineDescriptor(
                forSubmesh: submesh,
                vertexDescriptor: vertexDescriptor,
                providedVertexConstants: vertexRequired,
                providedFragmentConstants: fragmentRequired
        )

        let depthStencilDescriptor = getDepthStencilDescriptor(forSubrenderable: submesh)
        let falsePipelineState = makePipelineState(
                pipelineDescriptor: specPipelineDescriptor,
                depthStencilDescriptor: depthStencilDescriptor,
                device: specPipelineDescriptor.vertexFunction!.device
        )

        return makePipelineState(
                falsePipelineState: falsePipelineState,
                unsatisfiedConstantsVertex: vertexRequired,
                unsatisfiedConstantsFragment: fragmentRequired,
                depthStencilDescriptor: depthStencilDescriptor,
                submesh: submesh,
                vertexDescriptor: vertexDescriptor
        )
    }

    private func makePipelineState(falsePipelineState: RenderPipelineState,
                                   unsatisfiedConstantsVertex: [FunctionConstant],
                                   unsatisfiedConstantsFragment: [FunctionConstant],
                                   depthStencilDescriptor: MTLDepthStencilDescriptor,
                                   submesh: SubmeshItem,
                                   vertexDescriptor: OSMVertexDescriptor) -> RenderPipelineState {
        let constantBoundProperties = submesh.material.constantBoundProperties
        let vertexConstants = evaluateConstants(
                constantBoundProperties: constantBoundProperties,
                arguments: falsePipelineState.reflection.vertexHeader?.arguments ?? [],
                requiredConstants: unsatisfiedConstantsVertex
        )
        let fragmentConstants = evaluateConstants(
                constantBoundProperties: constantBoundProperties,
                arguments: falsePipelineState.reflection.fragmentHeader?.arguments ?? [],
                requiredConstants: unsatisfiedConstantsFragment
        )

        let specPipelineDescriptor = getPipelineDescriptor(
                forSubmesh: submesh,
                vertexDescriptor: vertexDescriptor,
                providedVertexConstants: vertexConstants,
                providedFragmentConstants: fragmentConstants
        )

        return makePipelineState(
                pipelineDescriptor: specPipelineDescriptor,
                depthStencilDescriptor: falsePipelineState.depthStencilDescriptor,
                device: falsePipelineState.pso.device
        )
    }

    private func makePipelineState(pipelineDescriptor: MTLRenderPipelineDescriptor,
                              depthStencilDescriptor: MTLDepthStencilDescriptor,
                              device: MTLDevice) -> RenderPipelineState {
        var reflection: MTLRenderPipelineReflection? = nil
        let options: MTLPipelineOption = [.argumentInfo, .bufferTypeInfo]
        let pso = try! device.makeRenderPipelineState(
                descriptor: pipelineDescriptor,
                options: options,
                reflection: &reflection
        )
        let dsState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)!
        return RenderPipelineState(
                pso: pso,
                vertexFunctionName: pipelineDescriptor.vertexFunction?.name,
                fragmentFunctionName: pipelineDescriptor.fragmentFunction?.name,
                mtlReflection: reflection!,
                depthStencilDescriptor: depthStencilDescriptor,
                depthStencilState: dsState
        )
    }

    func getPipelineDescriptor(forSubmesh submesh: SubmeshItem,
                               vertexDescriptor: OSMVertexDescriptor,
                               providedVertexConstants: [FunctionConstant],
                               providedFragmentConstants: [FunctionConstant]) -> MTLRenderPipelineDescriptor {
        let vertexFunction = getFunction(
                forSubrenderable: submesh,
                requiredConstants: providedVertexConstants,
                type: .vertex
        )
        let fragmentFunction = getFunction(
                forSubrenderable: submesh,
                requiredConstants: providedFragmentConstants,
                type: .fragment
        )

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor.makeMTLDescriptor()
        pipelineDescriptor.applyAttachments(pipelineColors)
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float

        return pipelineDescriptor
    }

    func getDepthStencilDescriptor(forSubrenderable subrenderable: SubmeshItem) -> MTLDepthStencilDescriptor {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .lessEqual
        descriptor.isDepthWriteEnabled = true
        return descriptor
    }

    private func getFunction(forSubrenderable subrenderable: SubmeshItem,
                             requiredConstants: [FunctionConstant],
                             type: RenderFunctionType) -> MTLFunction {
        let functionName = subrenderable.functionName(forType: type)
        let library = subrenderable.material.shader?.library ?? defaultLibrary

        let key = FunctionCache.Key(name: functionName, constants: requiredConstants)
        if let cachedFunction = functionCache.getFunction(forKey: key) { return cachedFunction }

        let result: MTLFunction
        do {
            if requiredConstants.count > 0 {
                let constantValues = MTLFunctionConstantValues()
                for constant in requiredConstants {
                    constant.setToValues(constantValues)
                }
                result = try library.makeFunction(name: functionName, constantValues: constantValues)
            } else {
                result = library.makeFunction(name: functionName)!
            }
        } catch {
            fatalError(error.localizedDescription)
        }

        functionCache.setFunction(result, forKey: key)
        return result
    }

    private func evaluateConstants(constantBoundProperties: [OSMMaterialSemantic: OSMMaterialProperty],
                                   arguments: [Argument],
                                   requiredConstants: [FunctionConstant]) -> [FunctionConstant] {
        var providedConstants: [FunctionConstant] = arguments.filter {
            guard let property = constantBoundProperties[OSMMaterialSemantic(rawValue: $0.name)!],
                  property.value.isCompatibleWithArgument($0) else { return false }

            return true
        }.map {
            /// Input values should exist
            let property = constantBoundProperties[OSMMaterialSemantic(rawValue: $0.name)!]!
            let constantIdx = property.functionConstantIndex!
            return FunctionConstant(index: constantIdx, flag: true)
        }

        let unsatisfiedConstants = requiredConstants.filter { required in
            !providedConstants.contains { provided in provided.index == required.index }
        }.map { FunctionConstant(index: $0.index, flag: false) }
        providedConstants.append(contentsOf: unsatisfiedConstants)

        return providedConstants
    }

    static func makeDefaultPipelineColors() -> [MTLRenderPipelineColorAttachmentDescriptor] {
        let descriptor = MTLRenderPipelineColorAttachmentDescriptor()
        descriptor.pixelFormat = .bgra8Unorm
        descriptor.isBlendingEnabled = true
        descriptor.rgbBlendOperation = .add
        descriptor.sourceRGBBlendFactor = .sourceAlpha
        descriptor.destinationRGBBlendFactor = .oneMinusSourceAlpha
        return [descriptor]
    }
}
