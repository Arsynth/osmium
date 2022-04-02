//
// Created by Artem Sechko on 23.02.2022.
//

import Foundation

extension OSMNode: Hashable {
    public static func ==(lhs: OSMNode, rhs: OSMNode) -> Bool {
        lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }
}
