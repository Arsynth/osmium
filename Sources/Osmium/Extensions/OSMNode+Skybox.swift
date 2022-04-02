//
// Created by Artem Sechko on 27.03.2022.
//

import Foundation
import Metal
import ModelIO
import MetalKit

private let kSkyboxVertexFunctionName = "skyboxVertex"
private let kSkyboxFragmentFunctionName = "skyboxFragment"
private let kSkyboxSemantic = OSMMaterialSemantic(rawValue: "skyboxCube")!

private extension OSMShader {
    static func skyboxShader(_ device: MTLDevice) -> OSMShader {
        OSMShader(
                vertexFunctionName: kSkyboxVertexFunctionName,
                fragmentFunctionName: kSkyboxFragmentFunctionName,
                library: makeDefaultLibrary(withDevice: device)
        )
    }
}

private extension MDLMesh {
    static func skyboxMesh(_ device: MTLDevice) -> MDLMesh {
        MDLMesh(
                boxWithExtent: float3(repeating: 0.9),
                segments: vector_uint3(repeating: 1),
                inwardNormals: true,
                geometryType: .triangles,
                allocator: MTKMeshBufferAllocator(device: device)
        )
    }
}

private extension OSMMesh {
    static func skyboxMesh(_ texture: MTLTexture) -> OSMMesh {
        guard texture.textureType == .typeCube else { fatalError("Texture should be type of cube") }
        let mdlMesh = MDLMesh.skyboxMesh(texture.device)
        let mesh = OSMMesh(withMDLMesh: mdlMesh, device: texture.device, addTangentBasis: false)

        let material = mesh.getMaterial(forSubmeshAtIndex: 0)
        material.setTexture(texture, semantic: kSkyboxSemantic)
        material.shader = OSMShader.skyboxShader(texture.device)

        return mesh
    }
}

extension OSMNode {
    static func skyboxNode(_ texture: MTLTexture) -> OSMNode {
        OSMNode(withMesh: OSMMesh.skyboxMesh(texture))
    }
}
