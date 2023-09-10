//
//  SettingAPI.swift
//  Network
//
//  Created by Young Bin on 2023/09/10.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation
import Moya

public enum SettingAPI {
    case withdrawal
}

extension SettingAPI: BaseAPI {
    public var path: String {
        switch self {
        case .withdrawal:
            return "members"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .withdrawal:
            return .delete
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .withdrawal:
            return .requestPlain
        }
    }
    
    public var sampleData: Data {
        """
        {
          "code": 200,
          "data": {},
          "message": "SUCCESS"
        }
        """
        .data(using: .utf8)!
    }
}
