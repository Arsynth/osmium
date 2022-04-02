//
// Created by Artem Sechko on 12.03.2022.
//

import Foundation
import Metal

let kSceneUniformsArgument = "sceneUniforms"
let kModelUniformsArgument = "modelUniforms"
let kLightsArgument = "lights"
let kMaterialUniformsArgument = "material"

typealias EncoderBlock = (MTLRenderCommandEncoder) -> Void

struct RenderCommand {
    /// An abstract object to hold in memory
    var ctx: AnyObject?
    var block: EncoderBlock

    init(ctx: AnyObject? = nil, block: @escaping EncoderBlock) {
        self.ctx = ctx
        self.block = block
    }

    static func makeStatesCommands(state: RenderPipelineState) -> [RenderCommand] {
        let pso = state.pso
        let psoCommand = RenderCommand {
            $0.setRenderPipelineState(pso)
        }
        let dsState = state.depthStencilState
        let dsStateCommand = RenderCommand {
            $0.setDepthStencilState(dsState)
        }
        return [psoCommand, dsStateCommand]
    }

    static func makeVertexInCommand(forMesh mesh: OSMMesh) -> RenderCommand {
        let vertexBuffers = mesh.vertexSource.vertexBuffers
        return RenderCommand {
            for (idx, buffer) in vertexBuffers.enumerated() {
                $0.setVertexBuffer(buffer.mtlBuffer, offset: buffer.offset, index: idx)
            }
        }
    }

    static func makeFrameConstantCommands(forReflection reflection: PipelineStateReflection,
                                          data: SceneRenderData) -> [RenderCommand] {
        var result: [RenderCommand] = []

        let sceneCommands = makeSceneUniformsCommands(
                forReflection: reflection,
                uniforms: data.sceneUniformsSource
        )
        result.append(contentsOf: sceneCommands)

        let lightingCommands = makeLightingCommands(
                forReflection: reflection,
                uniforms: data.lightsSource
        )
        result.append(contentsOf: lightingCommands)

        return result
    }

    private static func makeSceneUniformsCommands(forReflection reflection: PipelineStateReflection,
                                                  uniforms: OSMPointerSource) -> [RenderCommand] {
        var result: [RenderCommand] = []

        let vertexArgument = reflection.vertexHeader?.arguments.filter {
            $0.name == kSceneUniformsArgument
        }.first
        if let vertexArgument = vertexArgument {
            let command = RenderCommand {
                $0.setVertexBytes(uniforms.pointer.ptr, length: uniforms.pointer.length, index: vertexArgument.index)
            }
            result.append(command)
        }

        let fragmentArgument = reflection.fragmentHeader?.arguments.filter {
            $0.name == kSceneUniformsArgument
        }.first
        if let fragmentArgument = fragmentArgument {
            let command = RenderCommand {
                $0.setFragmentBytes(uniforms.pointer.ptr, length: uniforms.pointer.length, index: fragmentArgument.index)
            }
            result.append(command)
        }
        return result
    }

    private static func makeLightingCommands(forReflection reflection: PipelineStateReflection,
                                             uniforms: OSMPointerSource) -> [RenderCommand] {
        var result: [RenderCommand] = []

        let vertexArgument = reflection.vertexHeader?.arguments.filter {
            $0.name == kLightsArgument
        }.first
        if let vertexArgument = vertexArgument {
            let command = RenderCommand {
                $0.setVertexBytes(uniforms.pointer.ptr, length: uniforms.pointer.length, index: vertexArgument.index)
            }
            result.append(command)
        }

        let fragmentArgument = reflection.fragmentHeader?.arguments.filter {
            $0.name == kLightsArgument
        }.first
        if let fragmentArgument = fragmentArgument {
            let command = RenderCommand {
                $0.setFragmentBytes(uniforms.pointer.ptr, length: uniforms.pointer.length, index: fragmentArgument.index)
            }
            result.append(command)
        }
        return result
    }

    static func makeNodeConstantCommands(forReflection reflection: PipelineStateReflection,
                                         node: OSMNode) -> [RenderCommand] {
        var modelUniforms = node.modelUniforms
        let length = MemoryLayout<ModelUniforms>.stride
        var result: [RenderCommand] = []

        let vertexArgument = reflection.vertexHeader?.arguments.filter {
            $0.name == kModelUniformsArgument
        }.first
        if let vertexArgument = vertexArgument {
            let command = RenderCommand {
                $0.setVertexBytes(&modelUniforms, length: length, index: vertexArgument.index)
            }
            result.append(command)
        }

        let fragmentArgument = reflection.fragmentHeader?.arguments.filter {
            $0.name == kModelUniformsArgument
        }.first
        if let fragmentArgument = fragmentArgument {
            let command = RenderCommand {
                $0.setFragmentBytes(&modelUniforms, length: length, index: fragmentArgument.index)
            }
            result.append(command)
        }
        return result
    }

    static func makeMaterialUniformsCommands(forReflection reflection: PipelineStateReflection,
                                             renderable: SubmeshItem) -> [RenderCommand] {
        var materialUniforms = renderable.material.uniforms
        let length = MemoryLayout<MaterialUniforms>.stride
        var result: [RenderCommand] = []

        let vertexArgument = reflection.vertexHeader?.arguments.filter {
            $0.name == kMaterialUniformsArgument
        }.first
        if let vertexArgument = vertexArgument {
            let command = RenderCommand {
                $0.setVertexBytes(&materialUniforms, length: length, index: vertexArgument.index)
            }
            result.append(command)
        }

        let fragmentArgument = reflection.fragmentHeader?.arguments.filter {
            $0.name == kMaterialUniformsArgument
        }.first
        if let fragmentArgument = fragmentArgument {
            let command = RenderCommand {
                $0.setFragmentBytes(&materialUniforms, length: length, index: fragmentArgument.index)
            }
            result.append(command)
        }
        return result
    }

    static func makeMaterialCommands(forReflection reflection: PipelineStateReflection,
                                     renderable: SubmeshItem) -> [RenderCommand] {
        var result: [RenderCommand] = []
        let properties = renderable.material.properties
        if let args = reflection.vertexHeader?.arguments {
            let commands = makeMaterialCommands(
                    forArguments: args,
                    properties: properties,
                    device: renderable.state!.pso.device,
                    function: .vertex
            )
            result.append(contentsOf: commands)
        }
        if let args = reflection.fragmentHeader?.arguments {
            let commands = makeMaterialCommands(
                    forArguments: args,
                    properties: properties,
                    device: renderable.state!.pso.device,
                    function: .fragment
            )
            result.append(contentsOf: commands)
        }

        return result
    }

    static func makeDrawCommand(forSubmesh submesh: OSMSubmesh) -> RenderCommand {
        RenderCommand {
            $0.drawIndexedPrimitives(
                    type: submesh.primitiveType,
                    indexCount: submesh.indexCount,
                    indexType: submesh.indexType,
                    indexBuffer: submesh.indexBuffer,
                    indexBufferOffset: submesh.indexBufferOffset
            )
        }
    }

    static func makePushDebugGroupCommand(title: String) -> RenderCommand {
        RenderCommand {
            $0.pushDebugGroup(title)
        }
    }

    static func makePopDebugGroupCommand() -> RenderCommand {
        RenderCommand {
            $0.popDebugGroup()
        }
    }

    private static func makeMaterialCommands(forArguments arguments: [Argument],
                                             properties: [OSMMaterialSemantic: OSMMaterialProperty],
                                             device: MTLDevice,
                                             function: RenderFunctionType) -> [RenderCommand] {
        var result: [RenderCommand] = []
        for argument in arguments where argument.isActive == true {
            guard argument.type != .sampler else { continue } /// Will evaluated later

            /// Initializer will always returns value. If the raw value is unknown it will return `.userDefined(String)`
            let semantic = OSMMaterialSemantic(rawValue: argument.name)!
            let property = properties[semantic]
            guard let property = property,
                  property.value.isCompatibleWithArgument(argument) == true else {
                continue
            }

            let command = makeSetter(forValue: property.value, argument: argument, device: device, function: function)
            result.append(command)
        }

        let samplerSetters = makeSamplerSetters(
                forProperties: properties,
                arguments: arguments,
                device: device,
                function: function
        )
        result.append(contentsOf: samplerSetters)

        return result
    }

    private static func makeSetter(forValue value: OSMMaterialPropertyValue,
                                   argument: Argument,
                                   device: MTLDevice,
                                   function: RenderFunctionType) -> RenderCommand {
        switch argument.type {
        case .buffer: return makeBufferSetter(value: value, index: argument.index, function: function)
        case .texture: return makeTextureSetter(value: value, index: argument.index, function: function)
        case .sampler: return makeSamplerSetter(value: value, index: argument.index, function: function, device: device)
        }
    }

    private static func makeBufferSetter(value: OSMMaterialPropertyValue,
                                         index: Int,
                                         function: RenderFunctionType) -> RenderCommand {
        guard value.isNotEmpty else {
            fatalError("Value should not be empty in setter")
        }

        if value.isBuffer || value.isEmpty {
            let result = value.getBufferWithOffset()
            let buffer = result?.0
            let offset = result?.1 ?? 0
            switch function {
            case .vertex:
                return RenderCommand {
                    $0.setVertexBuffer(buffer, offset: offset, index: index)
                }
            case .fragment:
                return RenderCommand {
                    $0.setFragmentBuffer(buffer, offset: offset, index: index)
                }
            }
        } else if value.isBytes {
            return makeBytesSetter(value: value, index: index, function: function)
        } else {
            fatalError("OSMMaterialPropertyValue should be a buffer or bytes for buffer setting")
        }
    }

    private static func makeBytesSetter(value: OSMMaterialPropertyValue,
                                        index: Int,
                                        function: RenderFunctionType) -> RenderCommand {
        let data = value.getBytesData()!
        let holder = OSMUnsafePointer(data, deallocator: { $0.deallocate() })

        switch function {
        case .vertex:
            return RenderCommand(ctx: holder) {
                $0.setVertexBytes(holder.ptr, length: holder.length, index: index)
            }
        case .fragment:
            return RenderCommand(ctx: holder) {
                $0.setFragmentBytes(holder.ptr, length: holder.length, index: index)
            }
        }
    }

    private static func makeTextureSetter(value: OSMMaterialPropertyValue,
                                          index: Int,
                                          function: RenderFunctionType) -> RenderCommand {
        guard value.isNotEmpty else {
            fatalError("Value should not be empty in setter")
        }

        let texture = value.getTexture()
        switch function {
        case .vertex:
            return RenderCommand {
                $0.setVertexTexture(texture, index: index)
            }
        case .fragment:
            return RenderCommand {
                $0.setFragmentTexture(texture, index: index)
            }
        }
    }

    private static func makeSamplerSetters(forProperties properties: [OSMMaterialSemantic: OSMMaterialProperty],
                                           arguments: [Argument],
                                           device: MTLDevice,
                                           function: RenderFunctionType) -> [RenderCommand] {
        var result: [RenderCommand] = []
        for argument in arguments {
            if argument.type == .texture {
                let samplerArgument = arguments.argument(named: argument.counterpartSamplerName, withType: .sampler)
                if let samplerArgument = samplerArgument {
                    let value: OSMMaterialPropertyValue
                    if let property = properties[OSMMaterialSemantic(rawValue: argument.name)!],
                       property.value.hasSamplerDescriptor {
                        value = property.value
                    } else {
                        value = .samplerDescriptor(value: MaterialUtils.defaultSamplerStateDescriptor())
                    }

                    let samplerCommand = makeSamplerSetter(
                            value: value,
                            index: samplerArgument.index,
                            function: function,
                            device: device
                    )
                    result.append(samplerCommand)
                }
            }
        }
        return result
    }

    private static func makeSamplerSetter(value: OSMMaterialPropertyValue,
                                          index: Int,
                                          function: RenderFunctionType,
                                          device: MTLDevice) -> RenderCommand {
        guard value.isNotEmpty else {
            fatalError("Value should not be empty in setter")
        }

        let samplerDescriptor = value.getSamplerDescriptor()!
        let samplerState = device.makeSamplerState(descriptor: samplerDescriptor)!
        switch function {
        case .vertex:
            return RenderCommand {
                $0.setVertexSamplerState(samplerState, index: index)
            }
        case .fragment:
            return RenderCommand {
                $0.setFragmentSamplerState(samplerState, index: index)
            }
        }
    }
}
