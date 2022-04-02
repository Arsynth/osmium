//
// Created by Artem Sechko on 10.11.2021.
//

import Foundation
import Metal
import ModelIO
import MetalKit
import CoreImage
import Alloy

public class MaterialUtils {
    private static let mtlContext = try! MTLContext()
    private static let ciContext = CIContext(mtlDevice: mtlContext.device)

    public static func loadTexture(cgImage: CGImage, device: MTLDevice) throws -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: device)
        let texture = try textureLoader.newTexture(cgImage: cgImage, options: textureLoaderOptions)
        print("loaded texture from CGImage: \(cgImage)")
        return texture
    }

    public static func loadTexture(imageName: String, device: MTLDevice) throws -> MTLTexture? {
        // Prevent relative path from model I/O
        let fileName = URL(fileURLWithPath: imageName).lastPathComponent
        let textureLoader = MTKTextureLoader(device: device)

        let fileExtension =
                URL(fileURLWithPath: fileName).pathExtension.isEmpty ?
                        "png" : nil
        guard let url = Bundle.main.url(forResource: fileName,
                withExtension: fileExtension)
                else {
            let texture = try? textureLoader.newTexture(
                    name: fileName,
                    scaleFactor: 1.0,
                    bundle: Bundle.main,
                    options: nil
            )
            if texture != nil {
                print("loaded: \(fileName) from asset catalog")
            } else {
                print("Texture not found: \(fileName)")
            }
            return texture
        }

        let texture = try textureLoader.newTexture(URL: url, options: textureLoaderOptions)
        print("loaded texture: \(url.lastPathComponent)")
        return texture
    }

    public static func loadTexture(url: URL, device: MTLDevice) throws -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: device)
        let texture = try textureLoader.newTexture(URL: url, options: textureLoaderOptions)
        print("loaded texture: \(url)")
        return texture
    }

    public static func loadTexture(texture: MDLTexture, device: MTLDevice) throws -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: device)
        let texture = try? textureLoader.newTexture(texture: texture,
                options: textureLoaderOptions)
        print("loaded texture from MDLTexture")
        return texture
    }

    public static func loadTexture(ciImage: CIImage, commandBuffer: MTLCommandBuffer? = nil) -> MTLTexture? {
        guard let newTexture = try? mtlContext.texture(
                width: Int(ciImage.extent.width),
                height: Int(ciImage.extent.width),
                pixelFormat: .bgra8Unorm,
                usage: [.shaderRead, .shaderWrite, .renderTarget]
        ) else {
            return nil
        }
        ciContext.render(
                ciImage,
                to: newTexture,
                commandBuffer: commandBuffer,
                bounds: ciImage.extent,
                colorSpace: CGColorSpaceCreateDeviceRGB()
        )
        return newTexture
    }

    public static func defaultSamplerStateDescriptor() -> MTLSamplerDescriptor {
        let descriptor = MTLSamplerDescriptor()
        descriptor.sAddressMode = .repeat
        descriptor.tAddressMode = .repeat
        descriptor.mipFilter = .linear
        descriptor.minFilter = .linear
        descriptor.magFilter = .linear
        descriptor.maxAnisotropy = 8
        return descriptor
    }
}
