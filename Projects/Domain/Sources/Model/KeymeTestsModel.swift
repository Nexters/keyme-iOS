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
    public let color: Color
    
    public static var EMPTY: IconModel = .init(image: "", color: Color.hex(""))
}

public extension KeymeTestsDTO {
    func toIconModel() -> KeymeTestsModel {
        let nickname = data.owner.nickname
        let icons = data.questions.map {
            IconModel(image: $0.category.iconUrl,
                      color: Color.hex($0.category.color))
        }
        return KeymeTestsModel(nickname: nickname ?? "키미키미", icons: icons)
    }
}