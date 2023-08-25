//
//  MemberAPI.swift
//  Network
//
//  Created by 이영빈 on 2023/08/25.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation
import Moya

public enum MemberAPI {
    case fetch
}

extension MemberAPI: BaseAPI {
    public var path: String {
        switch self {
        case .fetch:
            return "members"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .fetch:
            return .get
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .fetch:
            return .requestPlain
        }
    }
    
    public var sampleData: Data {
        """
        {
            "id": 1,
            "name": "Test Member"
        }
        """
        .data(using: .utf8)!
    }
}
