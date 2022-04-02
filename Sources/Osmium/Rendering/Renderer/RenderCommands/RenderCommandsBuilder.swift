//
// Created by Artem Sechko on 12.03.2022.
//

import Foundation
import Metal

class RenderCommandBuilder {
    private let materialCommandBuilder = MaterialCommandsBuilder()

    func buildCommands(sceneData: SceneRenderData) -> [RenderCommand] {
        var result: [RenderCommand] = []

        for meshItem in sceneData.meshes {
            let mesh = meshItem.mesh
            result.append(.makePushDebugGroupCommand(title: mesh.name))
            result.append(.makeVertexInCommand(forMesh: mesh))

            for submeshItem in meshItem.submeshes {
                guard let state = submeshItem.state else {
                    fatalError("Render pipeline state is not assigned to SubmeshItem")
                }

                let submesh = submeshItem.submesh
                let reflection = state.reflection

                result.append(.makePushDebugGroupCommand(title: submesh.name))

                let statesCommands = RenderCommand.makeStatesCommands(state: state)
                result.append(contentsOf: statesCommands)

                let frameConstantCommands = RenderCommand.makeFrameConstantCommands(
                        forReflection: reflection,
                        data: sceneData
                )
                result.append(contentsOf: frameConstantCommands)

                let nodeConstantCommands = RenderCommand.makeNodeConstantCommands(forReflection: reflection, node: meshItem.node)
                result.append(contentsOf: nodeConstantCommands)

                result.append(contentsOf: materialCommandBuilder.makeCommands(renderable: submeshItem))

                result.append(.makeDrawCommand(forSubmesh: submesh))

                result.append(.makePopDebugGroupCommand())
            }
            result.append(.makePopDebugGroupCommand())
        }

        return result
    }
}

private class MaterialCommandsBuilder {
    func makeCommands(renderable: SubmeshItem) -> [RenderCommand] {
        guard let funcReflection = renderable.state?.reflection else {
            fatalError("Renderable is not prepared. No pipeline info")
        }

        var result: [RenderCommand] = []
        let uniformsCommands = RenderCommand.makeMaterialUniformsCommands(forReflection: funcReflection, renderable: renderable)
        result.append(contentsOf: uniformsCommands)

        let materialCommands = RenderCommand.makeMaterialCommands(forReflection: funcReflection, renderable: renderable)
        result.append(contentsOf: materialCommands)

        return result
    }
}
