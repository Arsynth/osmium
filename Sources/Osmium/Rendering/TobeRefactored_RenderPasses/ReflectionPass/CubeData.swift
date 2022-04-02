//
// Created by Artem Sechko on 08.10.2021.
//

import Foundation
import Metal
import simd

// https://developer.apple.com/documentation/metal/mtlrenderpassdescriptor/rendering_to_multiple_texture_slices_in_a_draw_command

/*
 Configure the Render Pass
When you configure the MTLRenderPassDescriptor, specify a texture array, cube map texture, or 3D texture as the color attachment.
You must also set the render pass descriptor’s renderTargetArrayLength property to the maximum number of slices that the shader can choose from.
For example, when rendering to a cube map texture, set the length to 6.

When rendering to texture arrays and cube maps, you can specify multiple attachments and render to all of them simultaneously.
You can’t render to multiple attachments if you specify a 3D texture.
Here’s an example that sets up the render pass descriptor with one cube map texture for color data and another for depth information:

MTLRenderPassDescriptor* reflectionPassDesc = [MTLRenderPassDescriptor renderPassDescriptor];
reflectionPassDesc.colorAttachments[0].texture    = _reflectionCubeMap;
reflectionPassDesc.depthAttachment.texture        = _reflectionCubeMapDepth;
reflectionPassDesc.renderTargetArrayLength        = 6;
 */
/*
struct CubeData {
    struct DepthLimit {
        var zNear: Float
        var zFar: Float
    }

    static let faceDirections: [float3] = [
        [1, 0, 0], // Right
        [-1, 0, 0], // Left
        [0, 1, 0], // Top
        [0, -1, 0], // Down
        [0, 0, 1], // Front
        [0, 0, -1]  // Back
    ]

    static let faceUps: [float3] = [
        [0, 1, 0],
        [0, 1, 0],
        [0, 0, -1],
        [0, 0, 1],
        [0, 1, 0],
        [0, 1, 0]
    ]

    let colorCube: MTLTexture
    let depthCube: MTLTexture
    let renderTargets: [RenderTarget]

    let depthLimit: DepthLimit

    init(withMetalConfig metalConfig: MetalConfig, resolution: Int, depthLimit: DepthLimit) {
        let colorDescriptor = MTLTextureDescriptor.textureCubeDescriptor(
                pixelFormat: metalConfig.colorPixelFormat,
                size: resolution,
                mipmapped: false
        )
        colorDescriptor.usage = [.renderTarget, .shaderRead]
        let colorTex = metalConfig.device.makeTexture(descriptor: colorDescriptor)!
        colorCube = colorTex

        let depthDescriptor = MTLTextureDescriptor.textureCubeDescriptor(
                pixelFormat: metalConfig.depthStencilPixelFormat,
                size: resolution,
                mipmapped: false
        )
        depthDescriptor.usage = [.renderTarget, .shaderRead]
        depthDescriptor.storageMode = .private
        let depthTex = metalConfig.device.makeTexture(descriptor: depthDescriptor)!
        depthCube = depthTex

        renderTargets = Self.makeTargets(colorTex: colorTex, depthTex: depthTex)

        self.depthLimit = depthLimit
    }

    func viewInfo(forFace face: Int, position: float3) -> ViewInfo {
        let viewMatrix = float4x4(
                eye: position,
                center: position + Self.faceDirections[face],
                up: Self.faceUps[face]
        )
        let projectionMatrix = float4x4(
                projectionFov: Float.pi / 2.0,
                near: depthLimit.zNear,
                far: depthLimit.zFar,
                aspect: 1.0
        )
        return ViewInfo(
                cameraPosition: position,
                viewMatrix: viewMatrix,
                projectionMatrix: projectionMatrix
        )
    }

    private static func makeTargets(colorTex: MTLTexture, depthTex: MTLTexture) -> [RenderTarget] {
        var result: [RenderTarget] = []
        for i in 0..<6 {
            let newDescriptor = Self.defaultDescriptor.copy() as! MTLRenderPassDescriptor
            newDescriptor.colorAttachments[0].texture = colorTex
            newDescriptor.colorAttachments[0].slice = i
            newDescriptor.depthAttachment.texture = depthTex
            newDescriptor.depthAttachment.slice = i
            result.append(newDescriptor)
        }
        return result
    }

    private static let defaultDescriptor: MTLRenderPassDescriptor = {
        let facesPassDescriptor = MTLRenderPassDescriptor()
        facesPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        facesPassDescriptor.colorAttachments[0].loadAction = .clear
        facesPassDescriptor.colorAttachments[0].storeAction = .store
        facesPassDescriptor.depthAttachment.clearDepth = 1
        facesPassDescriptor.depthAttachment.loadAction = .clear
        facesPassDescriptor.depthAttachment.storeAction = .dontCare
        return facesPassDescriptor
    }()
}
*/
