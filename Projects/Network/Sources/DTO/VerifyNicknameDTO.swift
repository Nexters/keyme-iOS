//
//  VerifyNicknameDTO.swift
//  Network
//
//  Created by Young Bin on 2023/08/24.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

public struct VerifyNicknameDTO: Decodable {
    let code: Int
    let message: String
    public let data: NicknameData
    
    public struct NicknameData: Decodable {
        let description: String
        public let valid: Bool
    }
}
