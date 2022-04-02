//
//  File.swift
//  
//
//  Created by Artem Sechko on 11.03.2022.
//

import Foundation
import ModelIO
import Metal

extension MTLSamplerMinMagFilter {
    init(mdlFilter: MDLMaterialTextureFilterMode) {
        switch mdlFilter {
        case .nearest: self = .nearest
        case .linear: self = .linear
        @unknown default: self = .nearest
        }
    }
}

extension MTLSamplerMipFilter {
    init(mdlFilter: MDLMaterialMipMapFilterMode) {
        switch mdlFilter {
        case .nearest: self = .nearest
        case .linear: self = .linear
        @unknown default: self = .notMipmapped
        }
    }
}

extension MTLSamplerAddressMode {
    init(mdlMode: MDLMaterialTextureWrapMode) {
        switch mdlMode {
        case .clamp: self = .clampToEdge
        case .repeat: self = .repeat
        case .mirror: self = .mirrorRepeat
        @unknown default: self = .clampToZero
        }
    }
}

extension MTLSamplerDescriptor {
    convenience init(textureFilter: MDLTextureFilter) {
        self.init()
        minFilter = MTLSamplerMinMagFilter(mdlFilter: textureFilter.minFilter)
        magFilter = MTLSamplerMinMagFilter(mdlFilter: textureFilter.magFilter)

        mipFilter = MTLSamplerMipFilter(mdlFilter: textureFilter.mipFilter)

        sAddressMode = MTLSamplerAddressMode(mdlMode: textureFilter.sWrapMode)
        tAddressMode = MTLSamplerAddressMode(mdlMode: textureFilter.tWrapMode)
        rAddressMode = MTLSamplerAddressMode(mdlMode: textureFilter.rWrapMode)
    }
}

extension MDLTextureFilter {
    var mtlSampler: MTLSamplerDescriptor {
        MTLSamplerDescriptor(textureFilter: self)
    }
}
