//
// Created by Artem Sechko on 23.02.2022.
//

import Foundation
import ModelIO

extension MDLAxisAlignedBoundingBox {
    var center: vector_float3 {
        (maxBounds + minBounds) / 2.0
    }
}
