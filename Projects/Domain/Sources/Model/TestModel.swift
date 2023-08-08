//
//  TestModel.swift
//  Domain
//
//  Created by 김영인 on 2023/07/29.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

import Network

public struct TestModel {
    public let hello: String
}

public extension TestDTO {
    func toModel() -> TestModel {
        return .init(hello: hello)
    }
}
