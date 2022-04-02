//
// Created by Artem Sechko on 29.03.2022.
//

import Foundation

private let defaultSceneUniforms: SceneUniforms = {
    let camera = OSMLookAtCamera()
    camera.near = 1.0
    camera.far = 2000.0
    let cameraUniforms = camera.uniforms(withTransform: .identity())
    return SceneUniforms(viewInfo: cameraUniforms, lightCount: 1)
}()

private let defaultLightUniforms: [LightUniforms] = {
    [AmbientLight(color: [1.0, 1.0, 1.0], intensity: 1.0).uniforms(withTransform: .identity())]
}()

class SceneDataController {
    let sceneData = SceneRenderData()

    init() {
        sceneData.sceneUniformsSource.setValue(defaultSceneUniforms)
        sceneData.lightsSource.setValues(defaultLightUniforms)
    }

    func update(withScene scene: OSMScene, pointOfView: OSMNode) {
        let lights = scene.lightingUniforms
        let viewInfo = pointOfView.cameraUniforms
        let sceneUniforms = SceneUniforms(viewInfo: viewInfo, lightCount: UInt32(lights.count))
        sceneData.lightsSource.setValues(lights)
        sceneData.sceneUniformsSource.setValue(sceneUniforms)
    }
}
