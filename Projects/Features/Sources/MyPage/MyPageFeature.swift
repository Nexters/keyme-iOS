//
//  MyPageFeature.swift
//  Features
//
//  Created by Young Bin on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture
import Domain
import DSKit
import Foundation
import SwiftUI
import Network

struct MyPageFeature: Reducer {
    struct State: Equatable {
        var shownFirstTime = true
        var circleDataList: [CircleData] = []
        var circleShown = false
    }
    enum Action: Equatable {
        case loadCircle
        case saveCircle([CircleData])
        case markViewAsShown
        case circleTapped
        case circleDismissed
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadCircle:
//                return .run { send in
//                    let response = try await KeymeAPIManager.shared.request(
//                        .myPage(.statistics(2)),
//                        object: CircleData.NetworkResult.self)
//
//                    await send(.saveCircle(response.toCircleData()))
//                }

                state.circleDataList = [
                    CircleData(
                        color: .hex("89B5F6"),
                        xPoint: 0.2068919881427701,
                        yPoint: 0.7022698911578201,
                        radius: 0.14644660940672627,
                        metadata: CircleMetadata(
                            icon: DSKitAsset.Image.감성.swiftUIImage,
                            keyword: "감성",
                            averageScore: 4.2,
                            myScore: 1)),
                    CircleData(
                        color: .hex("BF36FE"),
                        xPoint: -0.20710678118654763,
                        yPoint: -0.4925857155047088,
                        radius: 0.20710678118654754,
                        metadata: CircleMetadata(
                            icon: DSKitAsset.Image.계획적.swiftUIImage,
                            keyword: "계획적",
                            averageScore: 1.5,
                            myScore: 3)),
                    CircleData(
                        color: .hex("568049"),
                        xPoint: -0.2218254069479773,
                        yPoint: 0.6062444788590935,
                        radius: 0.29289321881345254,
                        metadata: CircleMetadata(
                            icon: DSKitAsset.Image.돈관리.swiftUIImage,
                            keyword: "돈관리",
                            averageScore: 2.7,
                            myScore: 2)),
                    CircleData(
                        color: .hex("A9DBC3"),
                        xPoint: -0.5857864376269051,
                        yPoint: 0.0,
                        radius: 0.4142135623730951,
                        metadata: CircleMetadata(
                            icon: DSKitAsset.Image.센스.swiftUIImage,
                            keyword: "센스",
                            averageScore: 3.2,
                            myScore: 3)),
                    CircleData(
                        color: .hex("643FFF"),
                        xPoint: 0.4142135623730951,
                        yPoint: 0.0,
                        radius: 0.5857864376269051,
                        metadata: CircleMetadata(
                            icon: DSKitAsset.Image.유머.swiftUIImage,
                            keyword: "유머",
                            averageScore: 5,
                            myScore: 5))
                ]
                
                return .none
            case .saveCircle(let data):
                state.circleDataList = data
                return .none
                
            case .markViewAsShown:
                state.shownFirstTime = false
                return .none
                
            case .circleTapped:
                state.circleShown = true
                return .none
                
            case .circleDismissed:
                state.circleShown = false
                return .none
            }
        }
    }
}

extension MyPageFeature {
    
}
