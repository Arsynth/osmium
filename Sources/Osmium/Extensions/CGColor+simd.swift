//
// Created by Artem Sechko 14.03.2022.
//

import Foundation
import CoreGraphics
import simd

extension CGColor {
    var float4Value: SIMD4<Float> {
        guard let components = components else { return [0.0, 0.0, 0.0, 0.0] }
        guard components.count >= 3 else {
            let level = Float(components[0])
            let alpha = Float(components[1])
            return [level, level, level, alpha]
        }

        let red = Float(components[0])
        let green = Float(components[1])
        let blue = Float(components[2])
        var alpha = Float(1.0)

        if components.count > 3 {
            alpha = Float(components[3])
        }

        return [red, green, blue, alpha]
    }
}
