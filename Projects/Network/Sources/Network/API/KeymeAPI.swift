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
    case auth(Authorization)
}

extension KeymeAPI {
    public enum MyPage {
        case statistics(Int, RequestType)
        
        public enum RequestType: String {
            case similar = "SIMILAR"
            case different = "DIFFERENT"
        }
    }
    
    public enum Authorization {
        case signIn(oauthType: OauthType, accessToken: String)
        
        public enum OauthType: String {
            case kakao = "KAKAO"
            case apple = "APPLE"
        }
    }
}

extension KeymeAPI: BaseAPI {
    public var path: String {
        switch self {
        case .test:
            return "/api"
            
        case .myPage(.statistics(let id, _)):
            return "/members/\(id)/statistics"
            
        case .auth(.signIn):
            return "/auth/login"
            
        case .registerPushToken:
            return "/members/devices"
            
        case .auth:
            return "/auth/login"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .test:
            return .get
        case .myPage(.statistics):
            return .get
        case .auth(.signIn):
            return .post
        case .registerPushToken:
            return .post
        case .auth:
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
        case .auth(.signIn(let oauthType, let accessToken)):
            return .requestParameters(
                parameters: [
                    "oauthType": oauthType.rawValue,
                    "token": accessToken
                ],
                encoding: JSONEncoding.prettyPrinted)
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
