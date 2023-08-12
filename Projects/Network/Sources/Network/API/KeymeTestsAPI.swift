//
//  KeymeTestsAPI.swift
//  Network
//
//  Created by 김영인 on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

import Moya

public enum KeymeTestsAPI {
    case onboarding
    case daily
}

extension KeymeTestsAPI: BaseAPI {
    public var path: String {
        switch self {
        case .onboarding:
            return "tests/onboarding"
        case .daily:
            return "tests/daily"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var task: Moya.Task {
        return .requestPlain
    }
    
    public var sampleData: Data {
        """
        {
          "data": {
            "presenterProfile": {
              "memberId": 0,
              "nickname": "키미키미키미",
              "thumbnailUrl": "string"
            },
            "questions": [
              {
                "category": {
                  "color": "FD7878",
                  "imageUrl": "https://ifh.cc/g/CAZW7F.png",
                  "name": "string"
                },
                "description": "불의를 보면 참지 않는다",
                "keyword": "참군인",
                "questionId": 0
              },
              {
                "category": {
                  "color": "FDF078",
                  "imageUrl": "https://ifh.cc/g/pYpd22.png",
                  "name": "string"
                },
                "description": "불의를 보면 참지 않는다",
                "keyword": "참군인",
                "questionId": 0
              }
            ],
            "solvedCount": 0,
            "testId": 0,
            "testResultId": 0,
            "title": "string"
          },
          "message": "SUCCESS",
          "state": "200"
        }
        """
            .data(using: .utf8)!
    }
}
