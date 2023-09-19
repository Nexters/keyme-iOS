//
//  KeymeTestsDTO.swift
//  Network
//
//  Created by 김영인 on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

public struct KeymeTestsDTO: Codable {
    let code: Int
    let message: String
    public let data: TestData
    
    public struct TestData: Codable {
        public let owner: Owner
        public let questions: [Question]
        public let testId: Int
        public let testResultId: Int?
        public let title: String
    }

    public struct Owner: Codable {
        let id: Int
        public let nickname: String
        let profileThumbnail: String
    }

    public struct Question: Codable {
        public let category: Category
        public let keyword: String
        let questionId: Int
        let title: String
    }
    
    public var isSolved: Bool {
        data.testResultId != nil
    }
}

public struct Category: Codable {
    public let color: String
    public let iconUrl: String
    let name: String
}
