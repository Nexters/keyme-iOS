//
//  MemberUpdateDTO.swift
//  Network
//
//  Created by Young Bin on 2023/08/23.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

public struct MemberUpdateDTO: Codable {
    let code: Int
    public let data: MemberData
    let message: String
    
    public struct MemberData: Codable {
        public let friendCode: String?
        public let id: Int
        public let nickname: String
        public let profileImage: String
        public let profileThumbnail: String
    }
}
