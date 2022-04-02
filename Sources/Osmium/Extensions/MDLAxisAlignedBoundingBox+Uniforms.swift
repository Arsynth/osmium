//
// Created by Artem Sechko on 15.12.2021.
//

import Foundation
import ModelIO

extension MDLAxisAlignedBoundingBox {
    var uniforms: BBox {
        BBox(minPosition: minBounds, maxPosition: maxBounds)
    }
}
