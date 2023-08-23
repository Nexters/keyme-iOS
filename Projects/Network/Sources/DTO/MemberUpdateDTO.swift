//
//  MemberUpdateDTO.swift
//  Network
//
//  Created by Young Bin on 2023/08/23.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

struct MemberUpdateDTO: Codable {
    let code: Int
    let data: MemberData
    let message: String
    
    struct MemberData: Codable {
        let friendCode: String
        let id: Int
        let nickname: String
        let profileImage: String
        let profileThumbnail: String
    }
}
