//
// Created by Artem Sechko on 29.09.2021.
//

import Foundation
import Metal

class FunctionCache {
    static let shared = FunctionCache()

    struct Key: Hashable, Equatable {
        let name: String
        let constants: [FunctionConstant]
    }

    private var dict: [Key: MTLFunction] = [:]

    func setFunction(_ function: MTLFunction, forKey key: Key) {
        dict[key] = function
    }

    func getFunction(forKey key: Key) -> MTLFunction? {
        dict[key]
    }
}
