//
// Created by Artem Sechko on 16.04.2021.
//

import Foundation

public enum KeyboardControl: UInt16 {
    case a =      0
    case d =      2
    case w =      13
    case s =      1
    case down =   125
    case up =     126
    case right =  124
    case left =   123
    case q =      12
    case e =      14
    case key1 =   18
    case key2 =   19
    case key0 =   29
    case space =  49
    case c =      8
}

extension KeyboardControl {
    var numericKey: Int? {
        switch self {
        case .key1: return 1
        case .key2: return 2
        case .key0: return 0
        default: return nil
        }
    }
}

public protocol KeyboardInteractable: AnyObject {
    func keyPressed(key: KeyboardControl, state: InputState) -> Bool
}
