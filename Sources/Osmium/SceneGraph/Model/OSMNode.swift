//
// Created by Артем on 20.12.2020.
//

import Foundation
import simd
import ModelIO
import Metal

private let kZeroAABB = MDLAxisAlignedBoundingBox(maxBounds: [0.0, 0.0, 0.0], minBounds: [0.0, 0.0, 0.0])

public typealias OSMNodeBoolBlock = (OSMNode) -> Bool

public class OSMNode {
    public let mesh: OSMMesh?
    public var camera: OSMCamera?
    public var light: OSMLight? {
        didSet {
            if light != nil {
                if oldValue != nil {
                    scene?.lightRemoved(fromNode: self)
                }
                scene?.lightDidSet(toNode: self)
            } else {
                scene?.lightRemoved(fromNode: self)
            }
        }
    }

    public var name: String?
    internal(set) public weak var scene: OSMScene? {
        didSet {
            if scene !== oldValue {
                for child in children {
                    child.scene = scene
                }
                scene?.nodeAdded(self)
                oldValue?.nodeRemoved(self)
            }
        }
    }

    // MARK: - Hierarchy
    internal(set) public weak var parent: OSMNode? {
        didSet {
            scene = parent?.scene
        }
    }
    internal(set) public var children: [OSMNode] = []

    public var transform: float4x4 {
        get {
            let scaleMatrix = float4x4(scaling: scale)
            let rotationMatrix = float4x4(rotation: rotation)
            let quaternion = simd_quatf(rotationMatrix)
            let translationMatrix = float4x4(translation: position)
            return translationMatrix * float4x4(quaternion) * scaleMatrix
        } set {
            scale = newValue.scale
            rotation = newValue.rotation
            position = newValue.translation
        }
    }

    public var scale: float3 = [1.0, 1.0, 1.0]
    public var rotation: float3 = [0.0, 0.0, 0.0]
    public var position: float3 = [0.0, 0.0, 0.0]

    public var worldTransform: float4x4 {
        if let parent = parent {
            return parent.worldTransform * transform
        }
        return transform
    }

    public var worldBoundingBox: MDLAxisAlignedBoundingBox {
        guard let aabb = mesh?.boundingBox else { return kZeroAABB }
        let position = (worldTransform * float4(aabb.center, 1.0)).xyz
        let length = aabb.maxBounds - aabb.minBounds
        let minBounds = position - length / 2.0
        let maxBounds = position + length / 2.0

        return MDLAxisAlignedBoundingBox(maxBounds: maxBounds, minBounds: minBounds)
    }

    public var opacity: CGFloat = 1.0

    // MARK: - Public

    // Initialize with full hierarchy
    public init(withMDLObject mdlObject: MDLObject, device: MTLDevice) {
        if let mdlMesh = mdlObject as? MDLMesh {
            mesh = OSMMesh(withMDLMesh: mdlMesh, device: device)
        } else {
            mesh = nil
        }
        transform = mdlObject.transform?.matrix ?? .identity()

        for mdlObject in mdlObject.children.objects {
            let child = OSMNode(withMDLObject: mdlObject, device: device)
            add(childNode: child)
        }
    }

    public init(withMesh mesh: OSMMesh? = nil) {
        self.mesh = mesh
    }

    public convenience init(withCamera camera: OSMCamera) {
        self.init(withMesh: nil)
        self.camera = camera
    }

    public convenience init(withLight light: OSMLight) {
        self.init(withMesh: nil)
        self.light = light
    }

    public convenience init(withChildren children: [OSMNode]) {
        self.init(withMesh: nil)
        add(children: children)
    }

    public final func add(childNode: OSMNode) {
        add(children: [childNode])
    }

    public final func add(children: [OSMNode]) {
        self.children.append(contentsOf: children)
        children.forEach { $0.parent = self }
    }

    public final func remove(childNode: OSMNode) {
        guard let index = (children.firstIndex {
            $0 === childNode
        }) else { return }
        children.remove(at: index)
        childNode.parent = nil
    }

    public final func removeChildren() {
        let childrenToRemove = children
        childrenToRemove.forEach { child in
            child.removeFromParent()
        }
    }

    public final func removeFromParent() {
        parent?.remove(childNode: self)
    }
}

extension OSMNode: OSMModelTiming  {
    public func updateWithTime(_ time: CFAbsoluteTime) {
        /// TBD for animations
    }
}

public extension OSMNode {
    var modelUniforms: ModelUniforms {
        let modelMatrix = worldTransform
        let normalMatrix = modelMatrix.upperLeft
        let aabb = worldBoundingBox.uniforms

        return ModelUniforms(
                modelMatrix: modelMatrix,
                normalMatrix: normalMatrix,
                position: float3.zeroPoint(withTransform: modelMatrix),
                bBox: aabb
        )
    }
}

public extension OSMNode {
    var lightUniforms: LightUniforms {
        guard let light = light else { fatalError("Node has no light") }
        return light.uniforms(withTransform: worldTransform)
    }
}

public extension OSMNode {
    var cameraUniforms: ViewInfo {
        guard let camera = camera else {
            let camera = OSMLookAtCamera()
            camera.near = 1.0
            camera.far = 2000.0
            return camera.uniforms(withTransform: float4x4(translation: [0.0, 40.0, -40.0]))
        }
        return camera.uniforms(withTransform: worldTransform)
    }
}

public extension OSMNode {
    func flatMap(predicate: OSMNodeBoolBlock = { _ in true }) -> [OSMNode] {
        var result: [OSMNode] = predicate(self) ? [self] : []
        for child in children {
            result.append(contentsOf: child.flatMap(predicate: predicate))
        }
        return result
    }

    /// May include 'self'
    func firstNodeWithMesh() -> OSMNode? {
        if mesh != nil {
            return self
        }

        for child in children {
            if let result = child.firstNodeWithMesh() {
                return result
            }
        }

        return nil
    }
}
