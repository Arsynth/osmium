//
// Created by Артем on 20.12.2020.
//

import Foundation
import CoreGraphics
import Metal
import simd

open class OSMScene {
    public let rootNode: OSMNode
    public var background: MTLTexture?

    private var hierarchyObservers: [UpdateObserver] = []
    private var lightNodes: [OSMNode] = []

    public init() {
        rootNode = OSMNode(withMesh: nil)
        rootNode.scene = self
        rootNode.name = "Root"
    }

    // MARK: - Internal methods
    func nodeAdded(_ node: OSMNode) {
        if node.light != nil {
            lightNodes.append(node)
        }
        hierarchyObservers.forEach { $0.didChangeBlock() }
    }

    func nodeRemoved(_ node: OSMNode) {
        if node.light != nil {
            lightNodes.removeNode(node)
        }
        hierarchyObservers.forEach { $0.didChangeBlock() }
    }

    func lightDidSet(toNode node: OSMNode) {
        lightNodes.append(node)
    }

    func lightRemoved(fromNode node: OSMNode) {
        lightNodes.removeNode(node)
    }
}

public extension OSMScene {
    func addHierarchyObserver() -> UpdateObserver {
        let observer = UpdateObserver(withObservable: self)
        hierarchyObservers.append(observer)
        return observer
    }
}

public extension OSMScene {
    var firstPointOfView: OSMNode {
        cameraNodes().first ?? rootNode
    }
    func cameraNodes() -> [OSMNode] {
        rootNode.flatMap { $0.camera != nil }
    }
}

public extension OSMScene {
    var lightingUniforms: [LightUniforms] {
        lightNodes.map { $0.lightUniforms }
    }
}

extension OSMScene: UpdateObservable {
    public func removeObserver(_ observer: UpdateObserver) {
        hierarchyObservers.removeAll { $0 === observer }
    }
}

extension OSMScene: OSMModelTiming {
    public func updateWithTime(_ time: CFAbsoluteTime) {
        rootNode.updateWithTime(time)
    }
}

private extension Array where Element == OSMNode {
    mutating func removeNode(_ node: OSMNode) {
        removeAll { $0 === node }
    }
}
