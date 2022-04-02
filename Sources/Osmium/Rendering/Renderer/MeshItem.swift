//
// Created by Artem Sechko on 13.11.2021.
//

import Foundation
import Metal

class SubmeshItem {
    let submesh: OSMSubmesh
    let material: OSMMaterial
    let opacity: CGFloat

    var state: RenderPipelineState? = nil

    init(submesh: OSMSubmesh, material: OSMMaterial, opacity: CGFloat) {
        self.submesh = submesh
        self.material = material
        self.opacity = opacity
    }
}

class MeshItem {
    let node: OSMNode
    let mesh: OSMMesh
    let submeshes: [SubmeshItem]

    init(node: OSMNode, mesh: OSMMesh, submeshes: [SubmeshItem]) {
        self.node = node
        self.mesh = mesh
        self.submeshes = submeshes
    }
}
