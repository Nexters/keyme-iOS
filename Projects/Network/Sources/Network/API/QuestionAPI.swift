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
    case scores(ownerId: Int, questionId: Int, limit: Int)
    case statistics(ownerId: Int, questionId: Int)
}

extension QuestionAPI: BaseAPI {
    public var path: String {
        switch self {
        case .scores(_, let questionId, _):
            return "questions/\(questionId)/result/scores"
        case .statistics(_, let questionId):
            return "questions/\(questionId)/result/statistics"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .scores, .statistics:
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
        
        case .statistics:
            return """
            {
              "code": 200,
              "data": {
                "avgScore": 0,
                "category": {
                  "color": "string",
                  "iconUrl": "string",
                  "name": "string"
                },
                "keyword": "참군인",
                "myScore": 0,
                "questionId": 0,
                "title": "불의를 보면 참지 않는다"
              },
              "message": "SUCCESS"
            }
            """.data(using: .utf8)!
        }
    }
    
    public var task: Task {
        switch self {
        case let .scores(ownerId, _, limit):
            return .requestParameters(
                parameters: [
                    "limit": limit,
                    "ownerId": ownerId
                ],
                encoding: URLEncoding.queryString)
            
        case let .statistics(ownerId, _):
            return .requestParameters(
                parameters: [
                    "ownerId": ownerId
                ],
                encoding: URLEncoding.queryString)
        }
    }
}
