//
//  KeymeAPI.swift
//  Keyme
//
//  Created by Young Bin on 2023/07/16.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

import Moya

public protocol KeymeAPI: TargetType { }

extension KeymeAPI {
    public var baseURL: URL {
        let baseURL = Bundle.main.infoDictionary?["API_BASE_URL"] as! String
        return URL(string: baseURL)!
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

// TODO: 나중에 어디로 옮기기
struct TestItem: Decodable {
    let id: Int
    let name: String
}
