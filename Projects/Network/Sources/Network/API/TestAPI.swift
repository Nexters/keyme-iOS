//
//  TestAPI.swift
//  Network
//
//  Created by 김영인 on 2023/07/29.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

import Moya

public enum TestAPI {
    case hello
}

extension TestAPI: BaseAPI {
    public var path: String {
        return "/hello"
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var task: Moya.Task {
        return .requestPlain
    }
    
    public var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}
