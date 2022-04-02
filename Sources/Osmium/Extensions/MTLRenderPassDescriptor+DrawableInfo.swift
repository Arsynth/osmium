//
// Created by Artem Sechko on 23.09.2021.
//

import Foundation
import Metal
import simd

extension MTLRenderPassDescriptor {
    var maxDrawableSize: SIMD2<Int32> {
        var maxSize: SIMD2<Int32> = [Int32(renderTargetWidth), Int32(renderTargetHeight)]
        if let colorTexture = colorAttachments[0].texture {
            maxSize.x = max(maxSize.x, Int32(colorTexture.width))
            maxSize.y = max(maxSize.y, Int32(colorTexture.height))
        }
        if let dsTexture = depthAttachment.texture {
            maxSize.x = max(maxSize.x, Int32(dsTexture.width))
            maxSize.y = max(maxSize.y, Int32(dsTexture.height))
        }
        return maxSize
    }
}
