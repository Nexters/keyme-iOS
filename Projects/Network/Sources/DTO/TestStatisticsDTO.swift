//
//  StatisticsDTO.swift
//  Network
//
//  Created by 김영인 on 2023/09/06.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

public struct TestStatisticsDTO: Codable {
    let code: Int
    let message: String
    public let data: StatisticsData
    
    public struct StatisticsData: Codable {
        public let averageRate: Double?
        public let questionsStatistics: [QuestionsStatisticsData]
        public let solvedCount: Int
    }
    
    public struct QuestionsStatisticsData: Codable {
        public let category: Category
        public let keyword, title: String
        public let avgScore: Double?
        public let questionId: Int
        public let myScore: Int?
    }
}

public typealias StatisticsData = TestStatisticsDTO.StatisticsData
public typealias QuestionsStatisticsData = TestStatisticsDTO.QuestionsStatisticsData

extension StatisticsData: Equatable {}

extension QuestionsStatisticsData: Equatable, Hashable {
    public static func == (lhs: TestStatisticsDTO.QuestionsStatisticsData, rhs: TestStatisticsDTO.QuestionsStatisticsData) -> Bool {
        lhs.questionId == rhs.questionId
    }
}
