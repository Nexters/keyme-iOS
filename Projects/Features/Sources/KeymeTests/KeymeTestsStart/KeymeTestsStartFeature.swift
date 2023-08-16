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
        public var isAnimating: Bool = false
        public var isOnboarding: Bool
        public var nickname: String?
        public var icon: IconModel = .EMPTY
        
        public init(isOnboarding: Bool) {
            self.isOnboarding = isOnboarding
        }
    }
    
    public enum Action {
        case viewWillAppear
        case fetchOnboardingTests(TaskResult<KeymeTestsModel>)
        case fetchDailyTests(TaskResult<KeymeTestsModel>)
        case startTests
        case setIcon(IconModel)
    }
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.keymeTestsClient) var keymeTestsClient
    
    public init() { }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
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
            case let .fetchOnboardingTests(.success(tests)),
                let .fetchDailyTests(.success(tests)):
                state.nickname = tests.nickname
                state.isAnimating.toggle()
                return .run { send in
                    repeat {
                        for icon in tests.icons {
                            await send(.setIcon(icon))
                            try await self.clock.sleep(for: .seconds(1.59))
                        }
                    } while true
                }
            case .fetchOnboardingTests(.failure),
                    .fetchDailyTests(.failure):
                state.nickname = nil
            case .startTests:
            // TODO: 웹뷰 구현
                return .none
            case let .setIcon(icon):
                state.icon = icon
            }
            return .none
        }
    }
}
