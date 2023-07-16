//
//  KeymeAPI.swift
//  Keyme
//
//  Created by Young Bin on 2023/07/16.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Moya
import Foundation

public enum KeymeAPI {
    case test
}

extension KeymeAPI: TargetType {
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
        return Data()
    }
}
