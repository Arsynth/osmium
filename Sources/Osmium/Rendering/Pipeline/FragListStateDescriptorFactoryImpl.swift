//
// Created by Artem Sechko on 11.08.2021.
//

import Foundation
import Metal
/*
final class FragListStateDescriptorFactoryImpl {
    private let factory: StateDescriptorFactory

    init() {
        let descriptors = StateDescriptorFactory.makeDefaultPipelineColors()
        .map {
            $0.pixelFormat = .invalid
            $0.isBlendingEnabled = false
        }
        factory = StateDescriptorFactory(
                withMetalConfig: metalConfig,
                fragmentFunctionName: "fragment_OIT_main",
                descriptorModifier: descriptorBlock
        )
    }

    func getPipelineDescriptor(forMesh mesh: OSMMesh,
                               material: OSMMaterial) -> MTLRenderPipelineDescriptor {
        factory.getPipelineDescriptor(forMesh: mesh, material: material)
    }

    func getDepthStencilDescriptor(forMesh mesh: OSMMesh, material: OSMMaterial) -> MTLDepthStencilDescriptor {
        factory.getDepthStencilDescriptor(forMesh: mesh, material: material)
    }
}
*/
