//
// Created by Artem Sechko on 28.10.2021.
//

import Foundation

public protocol UpdateObservable: AnyObject {
    func removeObserver(_ observer: UpdateObserver)
}

public class Disposer {
    private var observers: [UpdateObserver] = []
    func addObserver(_ updateObserver: UpdateObserver) {
        observers.append(updateObserver)
    }

    deinit {
        for observer in observers {
            observer.observable?.removeObserver(observer)
        }
    }
}

public class UpdateObserver {
    public var didChangeBlock: ()->() = {}
    weak var observable: UpdateObservable?

    init(withObservable observable: UpdateObservable) {
        self.observable = observable
    }

    public func disposed(by disposer: Disposer) {
        disposer.addObserver(self)
    }
}
