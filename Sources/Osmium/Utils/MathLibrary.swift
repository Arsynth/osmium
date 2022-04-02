//
// Created by Артем on 20.12.2020.
//

import simd

public typealias float2 = SIMD2<Float>
public typealias float3 = SIMD3<Float>
public typealias float4 = SIMD4<Float>

extension float3 {
    static func zeroPoint(withTransform transform: float4x4) -> float3 {
        float4.zeroPoint(withTransform: transform).xyz
    }
}

extension float4 {
    static func zeroPoint(withTransform transform: float4x4) -> float4 {
        transform * float4(0.0, 0.0, 0.0, 1.0)
    }
}

extension Float {
    var radiansToDegrees: Float {
        (self / Float.pi) * 180
    }
    var degreesToRadians: Float {
        (self / 180) * Float.pi
    }
}

public struct CameraRect {
    public var left: Float = 0
    public var right: Float = 0
    public var top: Float = 0
    public var bottom: Float = 0

    public init(left: Float, right: Float, top: Float, bottom: Float) {
        self.left = left
        self.right = right
        self.top = top
        self.bottom = bottom
    }
}

// MARK:- float4x4
extension float4x4 {
    // MARK:- Translate
    public init(translation: float3) {
        let matrix = float4x4(
                [            1,             0,             0, 0],
                [            0,             1,             0, 0],
                [            0,             0,             1, 0],
                [translation.x, translation.y, translation.z, 1]
        )
        self = matrix
    }

    // MARK:- Scale
    public init(scaling: float3) {
        let matrix = float4x4(
                [scaling.x,         0,         0, 0],
                [        0, scaling.y,         0, 0],
                [        0,         0, scaling.z, 0],
                [        0,         0,         0, 1]
        )
        self = matrix
    }

    public init(scaling: Float) {
        self = matrix_identity_float4x4
        columns.3.w = 1 / scaling
    }

    // MARK:- Rotate
    public init(rotationX angle: Float) {
        let matrix = float4x4(
                [1,           0,          0, 0],
                [0,  cos(angle), sin(angle), 0],
                [0, -sin(angle), cos(angle), 0],
                [0,           0,          0, 1]
        )
        self = matrix
    }

    public init(rotationY angle: Float) {
        let matrix = float4x4(
                [cos(angle), 0, -sin(angle), 0],
                [         0, 1,           0, 0],
                [sin(angle), 0,  cos(angle), 0],
                [         0, 0,           0, 1]
        )
        self = matrix
    }

    public init(rotationZ angle: Float) {
        let matrix = float4x4(
                [ cos(angle), sin(angle), 0, 0],
                [-sin(angle), cos(angle), 0, 0],
                [          0,          0, 1, 0],
                [          0,          0, 0, 1]
        )
        self = matrix
    }

    public init(rotation angle: float3) {
        let rotationX = float4x4(rotationX: angle.x)
        let rotationY = float4x4(rotationY: angle.y)
        let rotationZ = float4x4(rotationZ: angle.z)
        self = rotationX * rotationY * rotationZ
    }

    public init(rotationYXZ angle: float3) {
        let rotationX = float4x4(rotationX: angle.x)
        let rotationY = float4x4(rotationY: angle.y)
        let rotationZ = float4x4(rotationZ: angle.z)
        self = rotationY * rotationX * rotationZ
    }

    // MARK:- Identity
    public static func identity() -> float4x4 {
        matrix_identity_float4x4
    }

    // MARK:- Upper left 3x3
    var upperLeft: float3x3 {
        let x = columns.0.xyz
        let y = columns.1.xyz
        let z = columns.2.xyz
        return float3x3(columns: (x, y, z))
    }

    /// https://math.stackexchange.com/questions/237369/given-this-transformation-matrix-how-do-i-decompose-it-into-translation-rotati/3554913

    var translation: float3 {
        columns.3.xyz
    }

    var scale: float3 {
        float3(
                length(columns.0.xyz),
                length(columns.1.xyz),
                length(columns.2.xyz)
        )
    }

    /// https://stackoverflow.com/questions/21515755/how-to-calculate-the-angles-xyz-from-a-matrix4x4
    var rotation: float3 {
        var thetaX: Float = 0.0
        var thetaY: Float = 0.0
        var thetaZ: Float = 0.0

        thetaX = asin(columns.1.z)

        if thetaX < Float.pi / 2.0 {
            if thetaX > (-Float.pi / 2.0) {
                thetaZ = atan2(-columns.1.x, columns.1.y)
                thetaY = atan2(-columns.0.z, columns.2.z)
            } else {
                thetaZ = -atan2(columns.2.x, columns.0.x)
                thetaY = 0.0
            }
        } else {
            thetaZ = atan2(columns.2.x, columns.0.x)
            thetaY = 0.0
        }

        return [thetaX, thetaY, thetaZ]
    }

    // MARK: - Left handed projection matrix
    init(projectionFov fov: Float, near: Float, far: Float, aspect: Float, lhs: Bool = true) {
        let y = 1 / tan(fov * 0.5)
        let x = y / aspect
        let z = lhs ? far / (far - near) : far / (near - far)
        let X = float4( x,  0,  0,  0)
        let Y = float4( 0,  y,  0,  0)
        let Z = lhs ? float4( 0,  0,  z, 1) : float4( 0,  0,  z, -1)
        let W = lhs ? float4( 0,  0,  z * -near,  0) : float4( 0,  0,  z * near,  0)
        self.init()
        columns = (X, Y, Z, W)
    }

    // left-handed LookAt
    init(eye: float3, center: float3, up: float3) {
        let z = normalize(center-eye)
        let x = normalize(cross(up, z))
        let y = cross(z, x)

        let X = float4(x.x, y.x, z.x, 0)
        let Y = float4(x.y, y.y, z.y, 0)
        let Z = float4(x.z, y.z, z.z, 0)
        let W = float4(-dot(x, eye), -dot(y, eye), -dot(z, eye), 1)

        self.init()
        columns = (X, Y, Z, W)
    }

    // MARK:- Orthographic matrix
    init(orthoLeft left: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float) {
        let X = float4(2 / (right - left), 0, 0, 0)
        let Y = float4(0, 2 / (top - bottom), 0, 0)
        let Z = float4(0, 0, 1 / (far - near), 0)
        let W = float4((left + right) / (left - right),
                (top + bottom) / (bottom - top),
                near / (near - far),
                1)
        self.init()
        columns = (X, Y, Z, W)
    }

    init(orthographic rect: CameraRect, near: Float, far: Float) {
        let X = float4(2 / (rect.right - rect.left), 0, 0, 0)
        let Y = float4(0, 2 / (rect.top - rect.bottom), 0, 0)
        let Z = float4(0, 0, 1 / (far - near), 0)
        let W = float4((rect.left + rect.right) / (rect.left - rect.right),
                (rect.top + rect.bottom) / (rect.bottom - rect.top),
                near / (near - far),
                1)
        self.init()
        columns = (X, Y, Z, W)
    }

    // convert double4x4 to float4x4
    init(_ m: matrix_double4x4) {
        self.init()
        let matrix: float4x4 = float4x4(float4(m.columns.0),
                float4(m.columns.1),
                float4(m.columns.2),
                float4(m.columns.3))
        self = matrix
    }
}

// MARK:- float3x3
extension float3x3 {
    init(normalFrom4x4 matrix: float4x4) {
        self.init()
        columns = matrix.upperLeft.inverse.transpose.columns
    }
}

// MARK:- float4
extension float4 {
    var xyz: float3 {
        get {
            float3(x, y, z)
        }
        set {
            x = newValue.x
            y = newValue.y
            z = newValue.z
        }
    }

    // convert from double4
    init(_ d: SIMD4<Double>) {
        self.init()
        self = [Float(d.x), Float(d.y), Float(d.z), Float(d.w)]
    }
}


