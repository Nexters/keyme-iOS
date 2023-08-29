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
    case registerPushToken(RegisterPushTokenAPI)
    case auth(AuthorizationAPI)
    case registration(RegistrationAPI)
    case member(MemberAPI)
    case test(KeymeTestsAPI)
    case question(QuestionAPI)
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
        }
    }
    
    public var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
    
    public var sampleData: Data {
        """
        {
            "id": 1,
            "name": "Test Item"
        }
        """
        .data(using: .utf8)!
    }
}
