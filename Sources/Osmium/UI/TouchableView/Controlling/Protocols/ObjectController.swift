//
// Created by Artem Sechko on 15.05.2021.
//

import Foundation

protocol ObjectController {
    var keyboardInteractable: KeyboardInteractable? { get }
    var mouseInteractable: MouseInteractable? { get }
    var gestureInteractable: GestureInteractable? { get }
}
