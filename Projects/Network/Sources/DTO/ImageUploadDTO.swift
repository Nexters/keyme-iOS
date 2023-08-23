//
//  ImageUploadDTO.swift
//  Network
//
//  Created by Young Bin on 2023/08/23.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

struct ImageUploadDTO: Codable {
    let code: Int
    let data: ImageData
    let message: String
    
    struct ImageData: Codable {
        let originalUrl: String
        let thumbnailUrl: String
    }
}
