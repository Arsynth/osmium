//
// Created by Artem Sechko on 16.04.2021.
//

import Foundation
import simd

public enum MouseControl {
    case leftDown, leftUp, leftDrag, rightDown, rightUp, rightDrag, scroll, mouseMoved
}

public protocol MouseInteractable: AnyObject {
    func mouseEvent(mouse: MouseControl, state: InputState,
                    delta: float3, location: float2)
}
