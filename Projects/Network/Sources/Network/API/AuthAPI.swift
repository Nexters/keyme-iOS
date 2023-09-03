//
//  AuthAPI.swift
//  Network
//
//  Created by 이영빈 on 2023/08/25.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation
import Moya

public enum AuthorizationAPI {
    case signIn(oauthType: OauthType, accessToken: String)
    
    public enum OauthType: String {
        case kakao = "KAKAO"
        case apple = "APPLE"
    }
}

extension AuthorizationAPI: BaseAPI {
    public var path: String {
        switch self {
        case .signIn:
            return "auth/login"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .signIn:
            return .post
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .signIn(let oauthType, let accessToken):
            return .requestParameters(
                parameters: [
                    "oauthType": oauthType.rawValue,
                    "token": accessToken
                ],
                encoding: JSONEncoding.prettyPrinted)
        }
    }
}
