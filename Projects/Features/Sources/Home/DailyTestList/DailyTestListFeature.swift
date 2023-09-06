//
//  DailyTestFeature.swift
//  Features
//
//  Created by 김영인 on 2023/09/06.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture

import Domain
import Network

public struct DailyTestListFeature: Reducer {
    @Dependency(\.keymeAPIManager) private var network

    public struct State: Equatable {
        let testData: KeymeTestsModel
        var dailyStatistics: DailyStatisticsModel = .EMPTY
        
        init(testData: KeymeTestsModel) {
            self.testData = testData
        }
    }
    
    public enum Action {
        case viewWillAppear
        case fetchDailyStatistics
        case saveDailyStatistics(DailyStatisticsModel)
        case shareButtonDidTap
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .viewWillAppear:
                return .send(.fetchDailyStatistics)
                
            case .fetchDailyStatistics:
                return .run { [testId = state.testData.testId] send in
                    let dailyStatisticsData = try await network.request(.test(.statistics(testId)), object: StatisticsDTO.self)
//                    let dailyStatisticsData = try await network.requestWithSampleData(.test(.statistics(testId)), object: StatisticsDTO.self)
                    let dailyStatistics = dailyStatisticsData.toDailyStatisticsModel()
                    await send(.saveDailyStatistics(dailyStatistics))
                }
                
            case let .saveDailyStatistics(dailyStatistics):
                state.dailyStatistics = dailyStatistics
                
            default:
                return .none
            }
            
            return .none
        }
    }
}
