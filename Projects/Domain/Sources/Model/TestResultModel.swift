//
//  TestResultModel.swift
//  Domain
//
//  Created by 김영인 on 2023/08/18.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

import Network

public struct TestResultModel: Equatable, Hashable {
    public let title: String
    public let keyword: String
    public let score: Int
    public let icon: IconModel
    
    public static let EMPTY: TestResultModel = .init(
        title: "",
        keyword: "",
        score: 0,
        icon: IconModel.EMPTY)
}

public extension ResultDTO {
    func toModel() -> TestResultModel {
        return TestResultModel(
            title: title,
            keyword: keyword,
            score: score,
            icon: IconModel(imageURL: category.iconUrl,
                            color: Color.hex(category.color))
        )
    }
}
