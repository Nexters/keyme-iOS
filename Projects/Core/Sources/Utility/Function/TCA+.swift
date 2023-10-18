//
//  TCA+.swift
//  Core
//
//  Created by Young Bin on 2023/09/03.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture

private final class Ref<T: Equatable>: Equatable {
    var val: T
    init(_ v: T) {
        self.val = v
    }

    static func == (lhs: Ref<T>, rhs: Ref<T>) -> Bool {
        lhs.val == rhs.val
    }
}

/// 스택 오버플로우 방지용 래퍼
/// 참고: https://github.com/pointfreeco/swift-composable-architecture/discussions/488
@propertyWrapper
public struct Box<T: Equatable>: Equatable {
    private var ref: Ref<T>

    public init(_ x: T) {
        self.ref = Ref(x)
    }

    public var wrappedValue: T {
        get { ref.val }
        set {
            if !isKnownUniquelyReferenced(&ref) {
                ref = Ref(newValue)
                return
            }
            ref.val = newValue
        }
    }

    public var projectedValue: Box<T> {
        self
    }
}
