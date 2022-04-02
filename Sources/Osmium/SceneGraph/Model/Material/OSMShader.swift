//
//  Shader.swift
//  
//
//  Created by Artem Sechko on 25.02.2022.
//

import Foundation
import Metal

public class OSMShader {
    public var vertexFunctionName: String?
    public var fragmentFunctionName: String?
    public var library: MTLLibrary?
    public var isOpaque: Bool = true

    public init(vertexFunctionName: String? = nil,
                fragmentFunctionName: String? = nil,
                library: MTLLibrary? = nil) {
        self.vertexFunctionName = vertexFunctionName
        self.fragmentFunctionName = fragmentFunctionName
        self.library = library
    }
}

extension OSMShader {
    func functionName(forType type: RenderFunctionType) -> String? {
        switch type {
        case .vertex: return vertexFunctionName
        case .fragment: return fragmentFunctionName
        }
    }
}
