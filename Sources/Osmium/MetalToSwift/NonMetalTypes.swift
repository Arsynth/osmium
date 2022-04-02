//
//  File.swift
//  
//
//  Created by Artem Sechko on 12.03.2022.
//

import Foundation
import Metal

struct FrameConstantUniforms {
    let lights: [LightUniforms]
    let sceneUniforms: SceneUniforms

    func with(viewInfo: ViewInfo) -> FrameConstantUniforms {
        FrameConstantUniforms(lights: lights, sceneUniforms: sceneUniforms.with(viewInfo: viewInfo))
    }
}

private let kOitLayersCount: Int = 8

final class UniformsFactory {
    static func makeOITRenderPassUniforms(withRenderPassDescriptor descriptor: MTLRenderPassDescriptor) -> OITRenderPassUniforms {
        let renderTargetSize = descriptor.maxDrawableSize
        let pixelCount = Int(renderTargetSize.x * renderTargetSize.y)
        let fragmentsCount = pixelCount * kOitLayersCount

        return OITRenderPassUniforms(
                displaySize: [UInt32(renderTargetSize.x), UInt32(renderTargetSize.y)],
                fragListCapacity: UInt32(fragmentsCount)
        )
    }
}
