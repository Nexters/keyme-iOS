//
//  TestResultDTO.swift
//  Network
//
//  Created by 김영인 on 2023/08/18.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

public struct TestResultDTO: Codable {
    public let data: ResultDataDTO
    let message: String
    let code: Int
}

public struct ResultDataDTO: Codable {
    public let testResultId: Int?
    public let testId: Int
    public let results: [ResultDTO]
}

public struct ResultDTO: Codable {
    let questionId: Int
    public let title, keyword: String
    public let category: ResultCategoryDTO
    public let score: Int
}

public struct ResultCategoryDTO: Codable {
    public let color, iconUrl, name: String
}
