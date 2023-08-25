//
//  MyPageAPI.swift
//  Network
//
//  Created by 이영빈 on 2023/08/25.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation
import Moya

public enum MyPageAPI {
    case statistics(Int, RequestType)
    
    public enum RequestType: String {
        case similar = "SIMILAR"
        case different = "DIFFERENT"
    }
}

extension MyPageAPI: BaseAPI {
    public var path: String {
        switch self {
        case .statistics(let id, _):
            return "members/\(id)/statistics"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .statistics:
            return .get
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .statistics(_, let type):
            return .requestParameters(parameters: ["type": type.rawValue], encoding: URLEncoding.default)
        }
    }
}
