//
//  CommonVariable.swift
//  Features
//
//  Created by 이영빈 on 10/2/23.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture

public final class CommonVariable {
    var userId: Int!
    var nickname: String!
}

extension CommonVariable: DependencyKey {
    public static var liveValue = CommonVariable()
}

extension DependencyValues {
    public var commonVariable: CommonVariable {
        get { self[CommonVariable.self] }
        set { self[CommonVariable.self] = newValue }
    }
}
