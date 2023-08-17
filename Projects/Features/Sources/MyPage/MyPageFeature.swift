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

struct Coordinate {
    var x: Double
    var y: Double
    var r: Double
    var color: Color
}

struct MyPageFeature: Reducer {
    let firstCoordSet: [Coordinate] = [
        Coordinate(x: 0.2068919881427701, y: 0.7022698911578201, r: 0.14644660940672627, color: .hex("89B5F6")),
        Coordinate(x: -0.20710678118654763, y: -0.4925857155047088, r: 0.20710678118654754, color: .hex("BF36FE")),
        Coordinate(x: -0.2218254069479773, y: 0.6062444788590935, r: 0.29289321881345254, color: .hex("568049")),
        Coordinate(x: -0.5857864376269051, y: 0.0, r: 0.4142135623730951, color: .hex("A9DBC3")),
        Coordinate(x: 0.4142135623730951, y: 0.0, r: 0.5857864376269051, color: .hex("643FFF"))
    ].sorted {
        $0.x < $1.x
    }
    let firstMetadataList: [CircleMetadata] = [
        CircleMetadata(animationId: 0, icon: DSKitAsset.Image.body.swiftUIImage, keyword: "신체", averageScore: 4.2, myScore: 1),
        CircleMetadata(animationId: 1, icon: DSKitAsset.Image.food.swiftUIImage, keyword: "음식", averageScore: 1.5, myScore: 3),
        CircleMetadata(animationId: 2, icon: DSKitAsset.Image.inteligence.swiftUIImage, keyword: "지능", averageScore: 2.7, myScore: 2),
        CircleMetadata(animationId: 3, icon: DSKitAsset.Image.passion.swiftUIImage, keyword: "열정", averageScore: 3.2, myScore: 3),
        CircleMetadata(animationId: 4, icon: DSKitAsset.Image.relationship.swiftUIImage, keyword: "인간관계", averageScore: 5, myScore: 5)
    ]
    
    let secondCoordSet: [Coordinate] = [
        Coordinate(x: -7.501192400092408e-17, y: -0.7450735078542183, r: 0.23887741000873083, color: .hex("89B5F6")),
        Coordinate(x: 0.5746106413067903, y: 0.49912945003477455, r: 0.23887741000873083, color: .hex("BF36FE")),
        Coordinate(x: -7.501192400092408e-17, y: 0.45007081148749567, r: 0.33782367297890564, color: .hex("568049")),
        Coordinate(x: 0.47775482001746167, y: -0.21092738078560702, r: 0.47775482001746167, color: .hex("A9DBC3")),
        Coordinate(x: -0.47775482001746167, y: -0.21092738078560702, r: 0.47775482001746167, color: .hex("643FFF"))
    ].sorted {
        $0.x < $1.x
    }
    let secondMetadataList: [CircleMetadata] = [
        CircleMetadata(animationId: 0, icon: DSKitAsset.Image.emotional.swiftUIImage, keyword: "감성", averageScore: 3.2, myScore: 1),
        CircleMetadata(animationId: 1, icon: DSKitAsset.Image.planning.swiftUIImage, keyword: "계획적", averageScore: 1.5, myScore: 3),
        CircleMetadata(animationId: 2, icon: DSKitAsset.Image.money.swiftUIImage, keyword: "돈관리", averageScore: 2.7, myScore: 2),
        CircleMetadata(animationId: 3, icon: DSKitAsset.Image.sense.swiftUIImage, keyword: "센스", averageScore: 3.2, myScore: 3),
        CircleMetadata(animationId: 4, icon: DSKitAsset.Image.humor.swiftUIImage, keyword: "유머", averageScore: 5, myScore: 5)
    ]
    
    struct State: Equatable {
        var selectedSegment: MyPageSegment = .similar
        var shownFirstTime = true
        var circleDataList: [CircleData] = []
        var circleShown = false
    }
    enum Action: Equatable {
        case selectSegement(MyPageSegment)
        case loadCircle(MatchRate)
        case saveCircle([CircleData])
        case markViewAsShown
        case circleTapped
        case circleDismissed
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .selectSegement(let segment):
                state.selectedSegment = segment
                switch segment {
                case .different :
                    return .send(.loadCircle(.low5))
                case .similar :
                    return .send(.loadCircle(.top5))
                }
                
            case .loadCircle(let rate):
//                return .run { send in
//                    let response = try await KeymeAPIManager.shared.request(
//                        .myPage(.statistics(2)),
//                        object: CircleData.NetworkResult.self)
//
//                    await send(.saveCircle(response.toCircleData()))
//                }
                
                switch rate {
                case .top5:
                    state.circleDataList = zip(firstCoordSet, firstMetadataList)
                        .map { coord, metadata in
                            CircleData(
                                color: coord.color,
                                xPoint: coord.x,
                                yPoint: coord.y,
                                radius: coord.r,
                                metadata: metadata)
                        }
                    
                case .low5:
                    state.circleDataList = zip(secondCoordSet, secondMetadataList)
                        .map { coord, metadata in
                            CircleData(
                                color: coord.color,
                                xPoint: coord.x,
                                yPoint: coord.y,
                                radius: coord.r,
                                metadata: metadata)
                        }
                }
                
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
    enum MatchRate {
        case top5
        case low5
    }
}
