//
//  MyPageFeature.swift
//  Features
//
//  Created by Young Bin on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture
import Domain
import Foundation
import SwiftUI

struct MyPageFeature: Reducer {
    struct State: Equatable {
        var shownFirstTime = true
        var circleDataList: [CircleData] = []
    }
    enum Action: Equatable {
        case loadCircle
        case markViewAsShown
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadCircle:
                // TODO: API 갈아끼우기
                state.circleDataList = [
                    CircleData(
                        color: .blue,
                        xPoint: 0.2068919881427701,
                        yPoint: 0.7022698911578201,
                        radius: 0.14644660940672627,
                        metadata: CircleMetadata(icon: Image(systemName: "person.fill"), keyword: "표현력", score: 4.2)),
                    CircleData(
                        color: .red,
                        xPoint: -0.20710678118654763,
                        yPoint: -0.4925857155047088,
                        radius: 0.20710678118654754,
                        metadata: CircleMetadata(icon: Image(systemName: "person.fill"), keyword: "표현력", score: 4.2)),
                    CircleData(
                        color: .gray,
                        xPoint: -0.2218254069479773,
                        yPoint: 0.6062444788590935,
                        radius: 0.29289321881345254,
                        metadata: CircleMetadata(icon: Image(systemName: "person.fill"), keyword: "표현력", score: 4.2)),
                    CircleData(
                        color: .cyan,
                        xPoint: -0.5857864376269051,
                        yPoint: 0.0,
                        radius: 0.4142135623730951,
                        metadata: CircleMetadata(icon: Image(systemName: "person.fill"), keyword: "표현력", score: 4.2)),
                    CircleData(
                        color: .mint,
                        xPoint: 0.4142135623730951,
                        yPoint: 0.0,
                        radius: 0.5857864376269051,
                        metadata: CircleMetadata(icon: Image(systemName: "person.fill"), keyword: "표현력", score: 4.2))
                ]
                return .none
            case .markViewAsShown:
                state.shownFirstTime = false
                return .none
            }
        }
    }
}
