//
//  QuestionStatisticsDTO.swift
//  Network
//
//  Created by 이영빈 on 10/2/23.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

public struct QuestionStatisticsDTO: Codable {
    let code: Int
    public let data: StatisticsData
    let message: String
    
    public struct StatisticsData: Codable {
        public let avgScore: Float
        public let category: Category
        public let keyword: String
        public let myScore: Int
        public let questionId: Int
        public let title: String
    }
}
