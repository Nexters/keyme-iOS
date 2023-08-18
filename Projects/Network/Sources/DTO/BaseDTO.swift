//
//  BaseDTO.swift
//  Network
//
//  Created by 김영인 on 2023/08/18.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

public struct BaseDTO<T: Codable>: Codable {    
    public let code: Int
    public let data: T?
    public let message: String
}
