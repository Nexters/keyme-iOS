//
//  ShortURLResponse.swift
//  Domain
//
//  Created by Young Bin on 2023/08/18.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

public struct BitlyResponse: Decodable {
    public let createdAt: String
    public let id: String
    public let link: String
    public let longURL: String

    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case id, link
        case longURL = "long_url"
    }
}
