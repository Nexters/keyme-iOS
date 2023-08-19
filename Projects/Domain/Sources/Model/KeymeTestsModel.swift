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
    public let testId: Int
    public let icons: [IconModel]
}

public struct IconModel: Equatable, Hashable {
    public let imageURL: String
    public let color: Color
    
    public static let EMPTY: IconModel = .init(imageURL: "", color: Color.hex(""))
}

public extension KeymeTestsDTO {
    func toIconModel() -> KeymeTestsModel {
        let nickname = data.owner.nickname
        let icons = data.questions.map {
            IconModel(imageURL: $0.category.iconUrl,
                      color: Color.hex($0.category.color))
        }
        return KeymeTestsModel(nickname: nickname ?? "키미",
                               testId: data.testId,
                               icons: icons)
    }
}
