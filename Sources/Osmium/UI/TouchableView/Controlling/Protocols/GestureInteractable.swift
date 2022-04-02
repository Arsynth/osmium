//
// Created by Artem Sechko on 02.05.2021.
//

import Foundation
import CoreGraphics

public protocol GestureInteractable: AnyObject {
    func translation(withPoint point: CGPoint)
    func scroll(withDeltaX dX: CGFloat, dY: CGFloat, dZ: CGFloat)
    func magnify(withDelta delta: CGFloat)
}
