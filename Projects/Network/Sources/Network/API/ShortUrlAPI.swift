//
//  ShortUrlAPI.swift
//  Network
//
//  Created by Young Bin on 2023/08/18.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Moya
import Foundation

public enum ShortUrlAPI {
    case shortenURL(longURL: String)
}

extension ShortUrlAPI: TargetType {
    public var baseURL: URL {
        return URL(string: "https://api-ssl.bitly.com")!
    }
    
    public var path: String {
        switch self {
        case .shortenURL:
            return "v4/shorten"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .shortenURL:
            return .post
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        switch self {
        case .shortenURL(let longURL):
            return .requestParameters(parameters: ["long_url": longURL], encoding: JSONEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        var header = ["Content-Type": "application/json"]
        
        if let accessToken = Bundle.main.object(forInfoDictionaryKey: "BITLY_API_KEY") as? String {
            header["Authorization"] = "Bearer \(accessToken)"
        }
        
        return header
    }
}
