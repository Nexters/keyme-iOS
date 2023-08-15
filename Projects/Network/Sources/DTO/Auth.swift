//
//  Auth.swift
//  Network
//
//  Created by 고도현 on 2023/08/15.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

public struct KakaoOAuthResponse: Codable { // 카카오 API Response 관련 Model
    public let refreshTokenExpiresIn: Int
    public let tokenType: String
    public let refreshToken: String
    public let accessToken: String
    public let expiresIn: Int
    public let scope: String
    
    public init(refreshTokenExpiresIn: Int, tokenType: String, refreshToken: String, accessToken: String, expiresIn: Int, scope: String) {
        self.refreshTokenExpiresIn = refreshTokenExpiresIn
        self.tokenType = tokenType
        self.refreshToken = refreshToken
        self.accessToken = accessToken
        self.expiresIn = expiresIn
        self.scope = scope
    }
}

public struct AppleOAuthResponse: Codable, Equatable { // 애플 API Response 관련 Model
    public let user: String
    public let fullName: PersonNameComponents?
    public let name: String
    public let email: String?
    public let identifyToken: String?
    public let authorizationCode: String?
    
    public init(user: String,
                fullName: PersonNameComponents?,
                name: String,
                email: String?,
                identifyToken: String?,
                authorizationCode: String?) {
        self.user = user
        self.fullName = fullName
        self.name = name
        self.email = email
        self.identifyToken = identifyToken
        self.authorizationCode = authorizationCode
    }
}

public struct KeymeOAuthRequest: Codable { // KeyMe API Request 관련 Model
    public let oauthType: String
    public let token: String
    
    public init(oauthType: String, token: String) {
        self.oauthType = oauthType
        self.token = token
    }
}

public struct KeymeOAuthResponse: Codable { // KeyMe API Response 관련 Model
    public let code: Int // statusCode
    public let data: Data
    public let message: String
    
    public struct Data: Codable {
        public let id: Int
        public let friendCode: String?
        public let nickname: String?
        public let profileImage: String?
        public let profileTumbnail: String?
        public let token: Token
        
        public struct Token: Codable {
            public let accessToken: String
        }
    }
}
