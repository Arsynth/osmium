//
// Created by Artem Sechko on 29.03.2022.
//

import Foundation

typealias DeallocBlock = (UnsafeRawPointer) -> Void

class OSMUnsafePointer {
    var ptr: UnsafeMutableRawPointer {
        didSet {
            deallocator(oldValue)
        }
    }
    var length: Int
    let deallocator: DeallocBlock = { _ in }

    init(length: Int = 0, deallocator: DeallocBlock = { $0.deallocate() }) {
        ptr = UnsafeMutableRawPointer.allocate(byteCount: length, alignment: MemoryLayout<UInt8>.alignment)
        self.length = length
    }

    init(bytes: UnsafeRawPointer, length: Int, deallocator: DeallocBlock = { $0.deallocate() }) {
        ptr = UnsafeMutableRawPointer.allocate(byteCount: length, alignment: MemoryLayout<UInt8>.alignment)
        ptr.copyMemory(from: bytes, byteCount: length)
        self.length = length
    }

    init(bytesNoCopy: UnsafeMutableRawPointer, length: Int, deallocator: DeallocBlock) {
        ptr = bytesNoCopy
        self.length = length
    }

    init(_ data: Data, deallocator: DeallocBlock = { $0.deallocate() }) {
        let newPtr = UnsafeMutableRawPointer.allocate(byteCount: data.count, alignment: MemoryLayout<UInt8>.alignment)
        data.withUnsafeBytes { p in
            let pointer = p.baseAddress!
            newPtr.copyMemory(from: pointer, byteCount: data.count)
        }
        ptr = newPtr
        length = data.count
    }

    deinit {
        deallocator(ptr)
    }
}
