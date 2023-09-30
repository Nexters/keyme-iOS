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
public extension StatisticsData {
    static func mockData(questionCount: Int) -> StatisticsData {
        let questions = (1...questionCount).map { i -> QuestionsStatisticsData in
            return QuestionsStatisticsData(
                category: .init(color: "", iconUrl: "", name: ""),
                keyword: "Keyword \(i)",
                title: "Title \(i)",
                avgScore: Double(i * 10 % 101),
                questionId: -i,
                myScore: i * 5 % 101
            )
        }
        
        let statisticsData = StatisticsData(
            averageRate: Double(questionCount * 50 % 101),
            questionsStatistics: questions,
            solvedCount: questionCount
        )
        
        return statisticsData
    }
}

extension QuestionsStatisticsData: Equatable, Hashable {
    public static func == (lhs: TestStatisticsDTO.QuestionsStatisticsData, rhs: TestStatisticsDTO.QuestionsStatisticsData) -> Bool {
        lhs.questionId == rhs.questionId
    }
}
