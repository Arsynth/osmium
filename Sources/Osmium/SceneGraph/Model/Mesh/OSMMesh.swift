//
// Created by Артем on 20.12.2020.
//

import Metal
import ModelIO
import MetalKit

public class OSMMesh {
    let name: String

    public var vertexSource: OSMVertexSource

    public var boundingBox: MDLAxisAlignedBoundingBox

    public let submeshes: [OSMSubmesh]
    public var materials: [OSMMaterial]

    let defaultMaterial: OSMMaterial

    /// `addTangentBasis` is the workaround. It should be handled in other way
    public init(withMDLMesh mdlMesh: MDLMesh, device: MTLDevice, addTangentBasis: Bool = true) {
        name = mdlMesh.name
        boundingBox = mdlMesh.boundingBox
        if addTangentBasis {
            mdlMesh.addTangentBasis(
                    forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate,
                    tangentAttributeNamed: MDLVertexAttributeTangent,
                    bitangentAttributeNamed: MDLVertexAttributeBitangent
            )
        }
        let mtkMesh = try! MTKMesh(mesh: mdlMesh, device: device)

        vertexSource = OSMVertexSource(mtkMesh: mtkMesh)

        let submeshes = zip(mdlMesh.submeshes!, mtkMesh.submeshes).map { mesh -> OSMSubmesh in
            let submesh = OSMSubmesh(
                    mdlSubmesh: mesh.0 as! MDLSubmesh,
                    mtkSubmesh: mesh.1
            )
            return submesh
        }
        self.submeshes = submeshes

        let materials = mdlMesh.submeshes!.compactMap { submesh -> OSMMaterial? in
            guard let mdlMaterial = (submesh as! MDLSubmesh).material else { return nil }
            return OSMMaterial(material: mdlMaterial, device: device)
        }
        self.materials = materials
        defaultMaterial = OSMMaterial(device: device)
    }
}

public extension OSMMesh {
    func getMaterial(forSubmeshAtIndex submeshIndex: Int) -> OSMMaterial {
        guard materials.count > 0 else {
            return defaultMaterial
        }
        return materials[submeshIndex % materials.count]
    }
}