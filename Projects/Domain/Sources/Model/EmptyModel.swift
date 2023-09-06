//
//  EmptyModel.swift
//  Domain
//
//  Created by 김영인 on 2023/09/06.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

public extension DailyStatisticsModel {
    static var EMPTY: Self = .init(
        solvedCount: 0,
        testsStatistics: []
    )
}
