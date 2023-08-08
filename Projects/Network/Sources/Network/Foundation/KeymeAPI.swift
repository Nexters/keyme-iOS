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
}

extension KeymeAPI: BaseAPI {
    // TODO: 임시 - 서버 도메인 확정되면 변경할 것
    public var baseURL: URL {
        return URL(string: "https://randomuser.me")!
    }

    // TODO: 임시 - API 추가될 떄마다 변경
    public var path: String {
        switch self {
        case .test:
            return "/api"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .test:
            return .get
        }
    }

    public var task: Task {
        switch self {
        case .test:
            return .requestPlain
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
