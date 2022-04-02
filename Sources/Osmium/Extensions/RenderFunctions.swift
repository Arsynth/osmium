//
//  File.swift
//  
//
//  Created by Artem Sechko on 28.02.2022.
//

import Foundation

public enum RenderFunctionType {
    case vertex
    case fragment
}

public struct RenderFunctionOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static let fragment: RenderFunctionOptions = RenderFunctionOptions(rawValue: 1 << 0)
    static let vertex: RenderFunctionOptions = RenderFunctionOptions(rawValue: 1 << 1)
    static let both: RenderFunctionOptions = [.fragment, .vertex]
}
