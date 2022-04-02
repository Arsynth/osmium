//
// Created by Artem Sechko on 14.09.2021.
//

import Foundation
import Metal

import SceneKit

final class RenderPass {
    var scene: OSMScene {
        didSet {
            update()
        }
    }
    var pointOfView: OSMNode

    private let sceneDataController = SceneDataController()

    private let psoController = StatesMapper(defaultLibrary: kDefaultLibrary)
    private let commandBuilder = RenderCommandBuilder()

    private var renderCommands: [RenderCommand] = []

    init(scene: OSMScene, pointOfView: OSMNode) {
        self.scene = scene
        self.pointOfView = pointOfView
    }

    func execute(withRenderCommandEncoder renderCommandEncoder: MTLRenderCommandEncoder,
                 passDescriptor: MTLRenderPassDescriptor) {
        sceneDataController.update(withScene: scene, pointOfView: pointOfView)
        for renderCommand in renderCommands {
            renderCommand.block(renderCommandEncoder)
        }
    }

    private func update() {
        updateRenderData()
        rebuildCommands()
    }

    private func updateRenderData() {
        let sceneData = sceneDataController.sceneData
        sceneData.meshes = meshes(forScene: scene)
        psoController.mapToMeshes(sceneData.meshes)
    }

    private func rebuildCommands() {
        renderCommands = commandBuilder.buildCommands(sceneData: sceneDataController.sceneData)
    }

    private func meshes(forScene scene: OSMScene) -> [MeshItem] {
        let nodes = scene.rootNode.flatMap()

        var result: [MeshItem] = []
        for node in nodes {
            guard let mesh = node.mesh else { continue }
            var subrenderables: [SubmeshItem] = []
            for (index, submesh) in mesh.submeshes.enumerated() {
                let subrenderale = SubmeshItem(
                        submesh: submesh,
                        material: mesh.getMaterial(forSubmeshAtIndex: index),
                        opacity: node.opacity
                )
                subrenderables.append(subrenderale)
            }
            let renderable = MeshItem(node: node, mesh: mesh, submeshes: subrenderables)
            result.append(renderable)
        }

        if let skyboxTexture = scene.background {
            let skyboxNode = OSMNode.skyboxNode(skyboxTexture)
            let skyboxMesh = skyboxNode.mesh!
            let skyboxSubrenderable = SubmeshItem(
                    submesh: skyboxMesh.submeshes.first!,
                    material: skyboxMesh.getMaterial(forSubmeshAtIndex: 0),
                    opacity: 1.0
            )
            let skyboxRenderable = MeshItem(node: skyboxNode, mesh: skyboxMesh, submeshes: [skyboxSubrenderable])
            result.append(skyboxRenderable)
        }

        return result
    }
}
