//
// Created by Artem Sechko on 21.03.2022.
//

import Foundation

extension Data {
    init<T>(value: T) {
        var value = value
        self.init(bytes: &value, count: MemoryLayout<T>.stride)
    }
}

