//
//  KeymeTestsStartFeature.swift
//  Features
//
//  Created by 김영인 on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture

import Domain

public struct KeymeTestsStartFeature: Reducer {

    public struct State: Equatable {
        public var isOnboarding: Bool
        public var nickname: String?
        public var icons: [IconModel] = []
        
        public init(isOnboarding: Bool) {
            self.isOnboarding = isOnboarding
        }
    }
    
    public enum Action {
        case viewWillAppear
        case fetchOnboardingTests(TaskResult<KeymeTestsModel>)
        case fetchDailyTests(TaskResult<KeymeTestsModel>)
        case startTests
    }
    
    @Dependency(\.keymeTestsClient) var keymeTestsClient
    
    public init() { }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .fetchOnboardingTests(.success(tests)):
                state.nickname = tests.nickname
                state.icons = tests.icons
            case .fetchOnboardingTests(.failure):
                state.nickname = nil
            case let .fetchDailyTests(.success(tests)):
                state.nickname = tests.nickname
                state.icons = tests.icons
            case .fetchDailyTests(.failure):
                state.nickname = nil
            case .viewWillAppear:
                if state.isOnboarding {
                    return .run { send in
                        await send(.fetchOnboardingTests(
                            TaskResult { try await self.keymeTestsClient.fetchOnboardingTests() }
                        ))
                    }
                } else {
                    return .run { send in
                        await send(.fetchDailyTests(
                            TaskResult { try await self.keymeTestsClient.fetchDailyTests() }
                        ))
                    }
                }
            case .startTests:
                return .none
            }
            return .none
        }
    }
}
