//
//  KeymeTestsDTO.swift
//  Network
//
//  Created by 김영인 on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

public struct KeymeTestsDTO: Codable {
    public let data: DataDTO
    let message: String
    let code: Int
}

public struct DataDTO: Codable {
    public let testResultId: Int?
    public let owner: PresenterProfileDTO
    public let questions: [QuestionDTO]
    let solvedCount: Int
    public let testId: Int
    let title: String
}

public struct PresenterProfileDTO: Codable {
    let id: Int
    public let nickname: String?
    let profileThumbnail: String
}

public struct QuestionDTO: Codable {
    public let category: CategoryDTO
    let title, keyword: String
    let questionId: Int
}

public struct CategoryDTO: Codable {
    public let color, iconUrl, name: String
}
