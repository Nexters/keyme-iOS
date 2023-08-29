//
//  QuestionAPI.swift
//  Network
//
//  Created by 이영빈 on 2023/08/29.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Moya
import Foundation

public enum QuestionAPI {
    case scores(questionId: Int)
}

extension QuestionAPI: BaseAPI {
    public var path: String {
        switch self {
        case .scores(let questionId):
            return "questions/\(questionId)/result/scores"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .scores:
            return .get
        }
    }
    
    public var sampleData: Data {
        switch self {
        case .scores:
            return """
            {
              "code": 200,
              "data": {
                "hasNext": true,
                "results": [
                  {
                    "createdAt": "2023-08-29T04:30:18.366Z",
                    "id": 0,
                    "score": 0
                  }
                ],
                "totalCount": 0
              },
              "message": "SUCCESS"
            }
            """.data(using: .utf8)!
        }
    }
    
    public var task: Task {
        switch self {
        case .scores:
            return .requestPlain
        }
    }
}
