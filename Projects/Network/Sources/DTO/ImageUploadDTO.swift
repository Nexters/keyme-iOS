//
//  ImageUploadDTO.swift
//  Network
//
//  Created by Young Bin on 2023/08/23.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

public struct ImageUploadDTO: Codable {
    let code: Int
    public let data: ImageData
    let message: String
    
    public struct ImageData: Codable {
        public let originalUrl: String
        public let thumbnailUrl: String
    }
}
