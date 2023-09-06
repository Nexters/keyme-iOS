//
//  AuthDTO.swift
//  Domain
//
//  Created by 고도현 on 2023/08/15.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

public struct AuthDTO: Decodable, Equatable {
    public static func == (lhs: AuthDTO, rhs: AuthDTO) -> Bool {
        lhs.data.id == rhs.data.id
    }
    
    let code: Int
    let message: String
    public let data: UserData
    
    public init(code: Int, message: String, data: UserData) {
        self.code = code
        self.message = message
        self.data = data
    }
}

public extension AuthDTO {
    static var mock: Self {
        .init(code: 0, message: "", data: UserData(id: 0, nickname: "", friendCode: "", profileImage: "", profileThumbnail: "", token: Token(accessToken: "")))
    }
}

public struct UserData: Decodable {
    public let id: Int
    public let nickname: String?
    public let friendCode: String?
    public let profileImage: String?
    public let profileThumbnail: String?
    public let token: Token
}

public struct Token: Decodable {
    public let accessToken: String
}
