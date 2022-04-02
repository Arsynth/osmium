//
// Created by Artem Sechko on 27.03.2021.
//

import Foundation
import Metal

public let bundle = Bundle.module

public func makeDefaultLibrary(withDevice device: MTLDevice) -> MTLLibrary {
    let defaultLibrary: MTLLibrary
    do {
        defaultLibrary = try device.makeDefaultLibrary(bundle: bundle)
    } catch {
        fatalError("\(error)")
    }
    return defaultLibrary
}

public let kDefaultLibrary: MTLLibrary = {
    guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
        fatalError("Metal device not found")
    }
    return makeDefaultLibrary(withDevice: defaultDevice)
}()
