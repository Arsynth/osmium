//
// Created by Artem Sechko on 27.03.2021.
//

import Foundation

public protocol OSMModelTiming: AnyObject {
    func updateWithTime(_ time: CFAbsoluteTime)
}
