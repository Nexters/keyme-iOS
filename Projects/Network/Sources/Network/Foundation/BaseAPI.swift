//
//  BaseAPI.swift
//  Keyme
//
//  Created by Young Bin on 2023/07/16.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

import Moya

public protocol BaseAPI: TargetType { }

extension BaseAPI {
    public var baseURL: URL {
        guard let baseURL = Bundle.main.infoDictionary?["API_BASE_URL"] as? String else {
            return URL(string: "dummy")!
        }
        
        return URL(string: baseURL)!
    }
    
//    public var headers: [String: String]? {
//        return ["Content-type": "application/json"]
//    }
}
