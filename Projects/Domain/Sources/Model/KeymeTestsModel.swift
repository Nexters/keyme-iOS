//
//  KeymeTestsModel.swift
//  Domain
//
//  Created by 김영인 on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

import Core
import Network
import Kingfisher

public struct KeymeTestsModel: Equatable {
    public let nickname: String
    public let icons: [IconModel]
}

public struct IconModel: Equatable {
    public let image: String
    public let color: String
}

public extension KeymeTestsDTO {
    func toIconModel() -> KeymeTestsModel {
        let nickname = data.presenterProfile.nickname
        let icons = data.questions.map {
            IconModel(image: $0.category.imageUrl, color: $0.category.color)
        }
        return KeymeTestsModel(nickname: nickname, icons: icons)
    }
}
