//
//  KeymeAPI.swift
//  Network
//
//  Created by 김영인 on 2023/08/07.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation
import Moya

public enum KeymeAPI {
    case myPage(MyPageAPI)
    case registerPushToken(PushTokenAPI)
    case auth(AuthorizationAPI)
    case registration(RegistrationAPI)
    case member(MemberAPI)
    case test(KeymeTestsAPI)
    case question(QuestionAPI)
    case setting(SettingAPI)
}

extension KeymeAPI: BaseAPI {
    public var path: String {
        switch self {
        case .myPage(let api):
            return api.path
        case .registerPushToken(let api):
            return api.path
        case .auth(let api):
            return api.path
        case .registration(let api):
            return api.path
        case .member(let api):
            return api.path
        case .test(let api):
            return api.path
        case .question(let api):
            return api.path
        case .setting(let api):
            return api.path
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .myPage(let api):
            return api.method
        case .registerPushToken(let api):
            return api.method
        case .auth(let api):
            return api.method
        case .registration(let api):
            return api.method
        case .member(let api):
            return api.method
        case .test(let api):
            return api.method
        case .question(let api):
            return api.method
        case .setting(let api):
            return api.method
        }
    }
    
    public var task: Task {
        switch self {
        case .myPage(let api):
            return api.task
        case .registerPushToken(let api):
            return api.task
        case .auth(let api):
            return api.task
        case .registration(let api):
            return api.task
        case .member(let api):
            return api.task
        case .test(let api):
            return api.task
        case .question(let api):
            return api.task
        case .setting(let api):
            return api.task
        }
    }
    
    public var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
    
    public var sampleData: Data {
        switch self {
        case let .myPage(.statistics(_, type)):
            switch type {
            case .different:
                return """
                {
                  "code": 200,
                  "data": {
                    "memberId": 0,
                    "results": [
                      {
                        "coordinate": {
                          "r": 0.1213131,
                          "x": 0.1213131,
                          "y": -0.24213131
                        },
                        "questionStatistic": {
                          "avgScore": 0,
                          "category": {
                            "color": "string",
                            "iconUrl": "string",
                            "name": "string"
                          },
                          "keyword": "참군인",
                          "ownerScore": 0,
                          "questionId": 0,
                          "title": "불의를 보면 참지 않는다"
                        }
                      }
                    ]
                  },
                  "message": "SUCCESS"
                }
                """.data(using: .utf8)!
            case .similar:
                return """
                {
                  "code": 200,
                  "data": {
                    "memberId": 0,
                    "results": [
                      {
                        "coordinate": {
                          "r": 0.1213131,
                          "x": 0.1213131,
                          "y": -0.24213131
                        },
                        "questionStatistic": {
                          "avgScore": 0,
                          "category": {
                            "color": "string",
                            "iconUrl": "string",
                            "name": "string"
                          },
                          "keyword": "참군인",
                          "ownerScore": 0,
                          "questionId": 0,
                          "title": "불의를 보면 참지 않는다"
                        }
                      }
                    ]
                  },
                  "message": "SUCCESS"
                }
                """.data(using: .utf8)!
            }
        case let .test(testAPI):
            return testAPI.sampleData
        default:
            return Data()
        }
    }
}
