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
    struct State: Equatable {
        var selectedSegment: MyPageSegment = .similar
        var shownFirstTime = true
        var similarCircleDataList: [CircleData] = []
        var differentCircleDataList: [CircleData] = []
        var shownCircleDatalist: [CircleData] = []
        var circleShown = false
    }
    enum Action: Equatable {
        case selectSegement(MyPageSegment)
        case requestCircle(MatchRate)
        case saveCircle([CircleData], MatchRate)
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
                    state.shownCircleDatalist = state.differentCircleDataList
                case .similar :
                    state.shownCircleDatalist = state.similarCircleDataList
                }
                
                return .none
                
            // 서버 부하가 있으므로 웬만하면 한 번만 콜 할 것
            case .requestCircle(let rate):
                switch rate {
                case .top5:
                    return .run { send in
                        let response = try await KeymeAPIManager.shared.request(
                            .myPage(.statistics(2, .similar)),
                            object: CircleData.NetworkResult.self)
                        
                        await send(.saveCircle(response.toCircleData(), rate))
                    }
                    
                case .low5:
                    return .run { send in
                        let response = try await KeymeAPIManager.shared.request(
                            .myPage(.statistics(2, .different)),
                            object: CircleData.NetworkResult.self)
                        
                        await send(.saveCircle(response.toCircleData(), rate))
                    }
                }
                
            case .saveCircle(let data, let rate):
                switch rate {
                case .top5:
                    state.similarCircleDataList = data
                case .low5:
                    state.differentCircleDataList = data
                }
                
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
