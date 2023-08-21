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
    case test
    case myPage(MyPage)
    case registerPushToken(String)
}

public enum MyPage {
    case statistics(Int, RequestType)
    
    public enum RequestType: String {
        case similar = "SIMILAR"
        case different = "DIFFERENT"
    }
}

extension KeymeAPI: BaseAPI {
    public var baseURL: URL {
        return URL(string: "https://api.keyme.space")!
    }

    public var path: String {
        switch self {
        case .test:
            return "/api"
        case .myPage(.statistics(let id, _)):
            return "/members/\(id)/statistics"
        case .registerPushToken:
            return "/members/devices"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .test:
            return .get
        case .myPage(.statistics):
            return .get
        case .registerPushToken:
            return .post
        }
    }

    public var task: Task {
        switch self {
        case .test:
            return .requestPlain
        case .myPage(.statistics(_, let type)):
            return .requestParameters(parameters: ["type": type.rawValue], encoding: URLEncoding.default)
        case .registerPushToken(let token):
            return .requestParameters(parameters: ["token": token], encoding: JSONEncoding.default)
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
