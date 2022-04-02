//
// Created by Artem Sechko on 29.03.2022.
//

import Foundation

class OSMPointerSource {
    var pointer = OSMUnsafePointer()

    init() {

    }

    init(pointer: OSMUnsafePointer) {
        self.pointer = pointer
    }

    func setValue<T>(_ value: T) {
        var value = value
        let length = MemoryLayout<T>.stride
        pointer = OSMUnsafePointer(bytes: &value, length: length)
    }

    func setValues<T>(_ values: [T]) {
        var values = values
        let length = MemoryLayout<T>.stride * values.count
        pointer = OSMUnsafePointer(bytes: &values, length: length)
    }
}
