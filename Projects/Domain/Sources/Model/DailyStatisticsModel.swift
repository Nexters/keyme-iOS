//
//  DailyStatisticsModel.swift
//  Domain
//
//  Created by 김영인 on 2023/09/06.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

import Network

public struct DailyStatisticsModel: Equatable {
    public let solvedCount: Int
    public let testsStatistics: [TestsStatisticsModel]
}

public struct TestsStatisticsModel: Hashable, Equatable {
    public let keymeTests: KeymeTestsInfoModel
    public let avarageScore: Double?
}

public extension StatisticsDTO {
    func toDailyStatisticsModel() -> DailyStatisticsModel {
        let testsStatistics = data.questionsStatistics.map {
            TestsStatisticsModel(
                keymeTests: KeymeTestsInfoModel(
                    keyword: $0.keyword,
                    icon: IconModel(
                        imageURL: $0.category.iconUrl,
                        color: Color.hex($0.category.color)
                    )
                ),
                avarageScore: $0.avgScore
            )
        }
        
        return DailyStatisticsModel(
            solvedCount: data.solvedCount,
            testsStatistics: testsStatistics
        )
    }
}
