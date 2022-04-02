//
// Created by Artem Sechko on 29.03.2022.
//

import Foundation

class SceneRenderData {
    let sceneUniformsSource = OSMPointerSource()
    let lightsSource = OSMPointerSource()

    var meshes: [MeshItem] = []
}
