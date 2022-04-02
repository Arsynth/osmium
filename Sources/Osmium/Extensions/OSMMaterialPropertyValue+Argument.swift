//
// Created by Artem Sechko on 25.03.2022.
//

import Foundation

extension OSMMaterialPropertyValue {
    func isCompatibleWithArgument(_ argument: Argument) -> Bool {
        switch argument.type {
        case .buffer: return isBuffer || isBytes
        case .texture: return isTexture
        case .sampler: return isSamplerDescriptor
        }
    }
}
