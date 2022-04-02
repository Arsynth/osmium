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

        var loadedNodes = [OSMNode]()
        for i in 0..<asset.count {
            let topObject = asset.object(at: i)
            let node = OSMNode(withMDLObject: topObject, device: device)
            loadedNodes.append(node)
        }

        nodes = loadedNodes
    }
}