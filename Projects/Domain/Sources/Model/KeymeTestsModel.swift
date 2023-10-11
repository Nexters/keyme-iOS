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
    public let tests: [KeymeTestsInfoModel]
}

public struct KeymeTestsInfoModel: Hashable, Equatable {
    public let keyword: String
    public let title: String
    public let icon: IconModel
}

public struct IconModel: Equatable, Hashable {
    public let imageURL: String
    public let color: Color
    
    public static let EMPTY: IconModel = .init(imageURL: "", color: Color.hex(""))
}

public extension KeymeTestsDTO {
    func toKeymeTestsModel() -> KeymeTestsModel {
        let tests = data.questions.map {
            KeymeTestsInfoModel(
                keyword: $0.keyword,
                title: $0.title,
                icon: IconModel(
                    imageURL: $0.category.iconUrl,
                    color: Color.hex($0.category.color)
                )
            )
        }
        
        return KeymeTestsModel(nickname: data.owner.nickname,
                               testId: data.testId,
                               tests: tests)
    }
}
