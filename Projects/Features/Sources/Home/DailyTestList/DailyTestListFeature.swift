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
        var nickname: String {
            @Dependency(\.commonVariable) var commonVariable
            return commonVariable.nickname
        }
        let testData: KeymeTestsModel
        var dailyStatistics: StatisticsData?
        
        init(testData: KeymeTestsModel) {
            self.testData = testData
        }
    }
    
    public enum Action {
        case onAppear
        case onDisappear
        case fetchDailyStatistics
        case saveDailyStatistics(StatisticsData)
        case shareButtonDidTap
    }
    
    enum CancelID {
        case dailyTestList
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchDailyStatistics)
                
            case .onDisappear:
                return .cancel(id: CancelID.dailyTestList)
                
            case .fetchDailyStatistics:
                state.dailyStatistics = nil
                
                return .run { [testId = state.testData.testId] send in
                    let dailyStatisticsData = try await network.request(
                        .test(.statistics(testId)), object: TestStatisticsDTO.self
                    ).data
                    await send(.saveDailyStatistics(dailyStatisticsData))
                }
                .cancellable(id: CancelID.dailyTestList)
        
            case let .saveDailyStatistics(dailyStatistics):
                state.dailyStatistics = dailyStatistics
                
            default:
                return .none
            }
            
            return .none
        }
    }
}
