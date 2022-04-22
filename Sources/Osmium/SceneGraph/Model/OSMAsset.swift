//
// Created by Артем on 20.12.2020.
//

import ModelIO
import MetalKit

public class OSMAsset {
    public let url: URL
    public let nodes: [OSMNode]
    private let asset: MDLAsset

    public init(withFileName fileName: String, device: MTLDevice) {
        guard let assetURL = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            fatalError("Model: \(fileName) not found")
        }
        url = assetURL

        let allocator = MTKMeshBufferAllocator(device: device)
        asset = MDLAsset(
                url: assetURL,
                vertexDescriptor: MDLVertexDescriptor.defaultVertexDescriptor,
                bufferAllocator: allocator
        )
        // Some file formats containing textures instead of texture names so it should preload textures
        asset.loadTextures()

        var topObjects: [MDLObject] = []
        for i in 0..<asset.count {
            let topObject = asset.object(at: i)
            topObjects.append(topObject)
        }

        nodes = Self.makeHierarchy(withMDLObjects: topObjects, device: device)
    }

    private static func makeHierarchy(withMDLObjects mdlObjects: [MDLObject], device: MTLDevice) -> [OSMNode] {
        var queue = mdlObjects.map {
            ($0, OSMNode(withMDLObject: $0, device: device))
        }
        let result = queue.map { $0.1 }

        while queue.count > 0 {
            let element = queue.removeFirst()
            let childComponents = element.0.children
            /// Actually may be nil!
            guard childComponents != nil else { continue }
            let children = childComponents.objects.map { ($0, OSMNode(withMDLObject: $0, device: device)) }
            element.1.add(children: children.map { $0.1 })

            queue.append(contentsOf: children)
        }

        return result
    }
}