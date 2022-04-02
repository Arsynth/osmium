//
// Created by Artem Sechko on 28.03.2022.
//

import Foundation

public protocol OSMSceneRenderer {
    var scene: OSMScene { get set }
    var pointOfView: OSMNode { get set }
}
