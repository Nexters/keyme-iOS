//
//  KeymeTestsDTO.swift
//  Network
//
//  Created by 김영인 on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

public typealias Question = KeymeTestsDTO.Question
public typealias TestData = KeymeTestsDTO.TestData

public struct KeymeTestsDTO: Codable {
    let code: Int
    let message: String
    public let data: TestData
    
    public struct TestData: Codable, Equatable {
        public let owner: Owner
        public let questions: [Question]
        public let testId: Int
        public let testResultId: Int?
        public let title: String
    }

    public struct Owner: Codable, Equatable {
        let id: Int
        public let nickname: String
        let profileThumbnail: String
    }

    public struct Question: Codable, Equatable {
        public let category: Category
        public let keyword: String
        public let title: String
        public let questionId: Int
    }
    
    public var isSolved: Bool {
        data.testResultId != nil
    }
}

public struct Category: Codable, Hashable {
    public let color: String
    public let iconUrl: String
    let name: String
}

public let testQuestions: [Question] = [
    Question(
        category: Category(color: "F37952", iconUrl: "https://d2z2a95epq6bmg.cloudfront.net/icon/passion.png", name: "열정"),
        keyword: "주간아이돌",
        title: "님은 아이돌 덕질에 일가견이 있다.",
        questionId: 1
    ),
    Question(
        category: Category(color: "FFFFFF", iconUrl: "https://d2z2a95epq6bmg.cloudfront.net/icon/passion.png", name: "열정"),
        keyword: "주간아이돌",
        title: "님은 아이돌 덕질에 일가견이 있다.",
        questionId: 1
    ),
    Question(
        category: Category(color: "F37952", iconUrl: "https://d2z2a95epq6bmg.cloudfront.net/icon/passion.png", name: "열정"),
        keyword: "주간아이돌",
        title: "님은 아이돌 덕질에 일가견이 있다.",
        questionId: 1
    ),
    Question(
        category: Category(color: "F37952", iconUrl: "https://d2z2a95epq6bmg.cloudfront.net/icon/passion.png", name: "열정"),
        keyword: "주간아이돌",
        title: "님은 아이돌 덕질에 일가견이 있다.",
        questionId: 1
    ),
    Question(
        category: Category(color: "F37952", iconUrl: "https://d2z2a95epq6bmg.cloudfront.net/icon/passion.png", name: "열정"),
        keyword: "주간아이돌",
        title: "님은 아이돌 덕질에 일가견이 있다.",
        questionId: 1
    ),
    Question(
        category: Category(color: "F37952", iconUrl: "https://d2z2a95epq6bmg.cloudfront.net/icon/passion.png", name: "열정"),
        keyword: "주간아이돌",
        title: "님은 아이돌 덕질에 일가견이 있다.",
        questionId: 1
    )
]
