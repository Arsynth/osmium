//
// Created by Artem Sechko on 24.09.2021.
//

import Foundation
import Metal

final class StatesMapper {
    let defaultLibrary: MTLLibrary

    private let stateFactory: StateFactory

    init(defaultLibrary: MTLLibrary) {
        self.defaultLibrary = defaultLibrary
        stateFactory = StateFactory(defaultLibrary: defaultLibrary)
    }

    func mapToMeshes(_ meshes: [MeshItem]) {
        for mesh in meshes {
            let vertexDescriptor = mesh.mesh.vertexSource.vertexDescriptor
            for submesh in mesh.submeshes {
                preparePipeline(forSubmesh: submesh, vertexDescriptor: vertexDescriptor)
            }
        }
    }

    private func preparePipeline(forSubmesh submesh: SubmeshItem, vertexDescriptor: OSMVertexDescriptor) {
        /// TODO: Make cache with identified unspecialized pipeline states
        submesh.state = stateFactory.makePipelineState(forSubmesh: submesh, vertexDescriptor: vertexDescriptor)
    }
}

