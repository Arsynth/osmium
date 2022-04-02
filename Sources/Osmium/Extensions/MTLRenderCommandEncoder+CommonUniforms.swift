//
// Created by Artem Sechko on 23.09.2021.
//

import Foundation
import Metal

extension MTLRenderCommandEncoder {
    func setupUniforms(_ uniforms: FrameConstantUniforms) {
        setupLights(uniforms.lights, function: .fragment)
        setupSceneUniforms(uniforms.sceneUniforms, function: .both)
    }

    func setupLights(_ lights: [LightUniforms], function: RenderFunctionOptions) {
        var lights = lights
        if function.contains(.fragment) {
            setFragmentBytes(
                    &lights,
                    length: MemoryLayout<LightUniforms>.stride * lights.count,
                    index: Int(BufferIndex.lights.rawValue)
            )
        }
        if function.contains(.vertex) {
            setVertexBytes(
                    &lights,
                    length: MemoryLayout<LightUniforms>.stride * lights.count,
                    index: Int(BufferIndex.lights.rawValue)
            )
        }
    }

    func setupSceneUniforms(_ sceneUniforms: SceneUniforms, function: RenderFunctionOptions) {
        var uniforms = sceneUniforms
        if function.contains(.fragment) {
            setFragmentBytes(&uniforms, length: MemoryLayout<SceneUniforms>.stride, index: Int(BufferIndex.sceneUniforms.rawValue))
        }
        if function.contains(.vertex) {
            setVertexBytes(&uniforms, length: MemoryLayout<SceneUniforms>.stride, index: Int(BufferIndex.sceneUniforms.rawValue))
        }
    }
}
