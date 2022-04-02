//
// Created by Artem Sechko on 27.03.2021.
//

import Foundation
import simd

public class OSMCamera {
    public var fovDegrees: Float = 70.0
    public var fovRadians: Float {
        fovDegrees.degreesToRadians
    }
    public var aspect: Float = 1.0
    public var near: Float = 0.001
    public var far: Float = 100.0

    public func projectionMatrix() -> float4x4 {
        float4x4(projectionFov: fovRadians,
                near: near,
                far: far,
                aspect: aspect)
    }

    public func viewMatrix(forTransform transform: float4x4) -> float4x4 {
        transform.inverse
    }

    public func uniforms(withTransform transform: float4x4) -> ViewInfo {
        let projection = projectionMatrix()
        let view = viewMatrix(forTransform: transform)
        let position = float3.zeroPoint(withTransform: transform)
        return ViewInfo(cameraPosition: position, viewMatrix: view, projectionMatrix: projection)
    }
}

public class OSMOrthographicCamera: OSMCamera {
    public var rect = CameraRect(left: 10.0, right: 10.0, top: 10.0, bottom: 10.0)

    public init(rect: CameraRect, near: Float, far: Float) {
        super.init()
        self.rect = rect
        self.near = near
        self.far = far
    }

    override public func projectionMatrix() -> float4x4 {
        float4x4(orthographic: rect, near: near, far: far)
    }
}

public class OSMLookAtCamera: OSMCamera {
    var front = float3(0.0, 0.0, -1.0)
    var forwardVector: float3 {
        front
    }
    var right: float3 {
        let up = float3(0.0, 1.0, 0.0)
        return normalize(cross(up, forwardVector))
    }
    var up: float3 {
        cross(forwardVector, right)
    }

    public override init() {
        super.init()
    }

    override public func viewMatrix(forTransform transform: float4x4) -> float4x4 {
        let position = float3.zeroPoint(withTransform: transform)
        return float4x4(
                eye: position,
                center: position + forwardVector,
                up: up
        )
    }
}
