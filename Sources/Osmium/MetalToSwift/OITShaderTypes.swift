//
//  File.swift
//  
//
//  Created by Artem Sechko on 11.03.2022.
//

import Foundation
import simd

struct ListItem {
    var color: float4
    var z: Float
    var next: UInt32
}

public struct OITComposeVertex {
    var position: float2
}

public struct OITRenderPassUniforms {
    var displaySize: simd_uint2
    var fragListCapacity: UInt32
}
