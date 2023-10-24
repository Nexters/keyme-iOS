//
//  KeymeWebViewModel.swift
//  Domain
//
//  Created by 김영인 on 2023/08/18.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

public struct KeymeWebViewModel: Codable, Equatable {
    public let matchRate: Float
    public let resultCode: String?
    public let testResultId: Int
    
    public init(matchRate: Float, resultCode: String?, testResultId: Int) {
        self.matchRate = matchRate
        self.resultCode = resultCode
        self.testResultId = testResultId
    }
}
