//
//  RegisterPushTokenAPI.swift
//  Network
//
//  Created by 이영빈 on 2023/08/25.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation
import Moya

public enum RegisterPushTokenAPI {
    case register(String)
}

extension RegisterPushTokenAPI: BaseAPI {
    public var path: String {
        switch self {
        case .register:
            return "members/devices"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .register:
            return .post
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .register(let token):
            return .requestParameters(parameters: ["token": token], encoding: JSONEncoding.default)
        }
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
