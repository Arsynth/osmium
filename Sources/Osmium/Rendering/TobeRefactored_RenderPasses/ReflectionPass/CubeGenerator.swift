//
// Created by Artem Sechko on 09.10.2021.
//

import Foundation
import Metal
/*
class CubeGenerator {
    private var reflectiveRenderables: [Subrenderable] = [] {
        didSet {
            prepareCubesToRender()
        }
    }
    private var cubeByNode: [OSMNode: CubeData] = [:]

    private let metalConfig: MetalConfig
    private let cubesResolution: Int

    private var renderPass: BaseRenderPassImpl!

    private var meshToSkip: OSMMesh?

    init(withMetalConfig metalConfig: MetalConfig, cubesResolution: Int) {
        self.metalConfig = metalConfig
        self.cubesResolution = cubesResolution

        let skipBlock: RenderIterationBlock = { [weak self] iteration -> Bool in
            guard let self = self else { return true }
            return iteration.renderable.mesh === self.meshToSkip
        }

        let renderableController = BaseRenderableControllerImpl.makeForOpaque(withMetalConfig: metalConfig)
        let traverse = RenderableHandler(
                withRenderableController: renderableController,
                sequenceFactory: RenderSequenceFactory(shouldSkipBlock: skipBlock),
                defaultDepthStencilState: defaultDepthStencilState(withMetalConfig: metalConfig)!
        )

        renderPass = BaseRenderPassImpl(
                withMetalConfig: metalConfig,
                renderTraverse: traverse
        )
    }

    func updateWithReflectiveRenderables(_ reflectiveRenderables: [Subrenderable], reflectedNodes: [OSMNode]) {
        renderPass.updateWithNodes(reflectedNodes)
        self.reflectiveRenderables = reflectiveRenderables
    }

    func generate(withCommandBuffer commandBuffer: MTLCommandBuffer, encoderBoundUniforms: FrameConstantUniforms) {
        for renderable in reflectiveRenderables {
            meshToSkip = renderable.mesh
            let position = renderable.node.worldBoundingBox.center
            for i in 0..<renderable.submeshIndices.count {
                guard let cube = renderable.prerenderedTextures[i].reflectionCube else { continue }
                for face in 0..<6 {
                    let viewInfo = cube.viewInfo(forFace: face, position: position)
                    let target = cube.renderTargets[face]
                    let newEncoderUniforms = encoderBoundUniforms.with(viewInfo: viewInfo)

                    let dbg_Submesh = renderable.submeshes[i]
                    renderPass.label = "Cube[\(face + 1)]-\(renderable.mesh.name)/\(dbg_Submesh.name)"

                    renderPass.execute(
                            withCommandBuffer: commandBuffer,
                            renderTarget: target,
                            encoderBoundUniforms: newEncoderUniforms
                    )
                }
            }
        }
    }

    private func prepareCubesToRender() {
        cubeByNode = [:]
        let reflectiveRenderablesByNode = Dictionary(grouping: reflectiveRenderables) { $0.node }
        for node in reflectiveRenderablesByNode.keys {
            cubeByNode[node] = CubeData(
                    withMetalConfig: metalConfig,
                    resolution: cubesResolution,
                    depthLimit: CubeData.DepthLimit(zNear: 1.0, zFar: 2000.0)
            )
            reflectiveRenderablesByNode[node]?.forEach { renderable in
                for i in 0..<renderable.submeshIndices.count {
                    renderable.prerenderedTextures[i].reflectionCube = cubeByNode[node]
                }
            }
        }
    }
}


func defaultDepthStencilState(withDevice device: MTLDevice) -> MTLDepthStencilState? {
    let descriptor = MTLDepthStencilDescriptor()
    descriptor.depthCompareFunction = .less
    descriptor.isDepthWriteEnabled = true
    return device.makeDepthStencilState(descriptor: descriptor)
}*/
