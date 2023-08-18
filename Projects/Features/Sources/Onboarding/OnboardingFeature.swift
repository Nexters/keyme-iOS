//
//  Onboarding.swift
//  Features
//
//  Created by 이영빈 on 2023/08/10.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation
import ComposableArchitecture

import DSKit
import Domain

public enum LottieType: CaseIterable {
    case splash1
    case splash2
    case splash3
    case question
    
    var lottie: AnimationAsset {
        switch self {
        case .splash1:
            return AnimationAsset.splash1
        case .splash2:
            return AnimationAsset.splash2
        case .splash3:
            return AnimationAsset.splash3
        case .question:
            return AnimationAsset.question
        }
    }
    
    var title: String {
        switch self {
        case .splash1:
            return "친구들이 생각하는\n나의 성격을 발견하고"
        case .splash2:
            return "내가 생각한 나의 성격과\n비교해보세요"
        case .splash3:
            return ""
        case .question:
            return "환영해요 키미님!\n이제 문제를 풀어볼까요?"
        }
    }
}

public struct OnboardingFeature: Reducer {
    public enum Status: Equatable {
        case notDetermined
        case completed
        case needsOnboarding
    }
    
    public struct State: Equatable {
        public var status: Status = .notDetermined
        
        public var keymeTests: KeymeTestsFeature.State?
        public var testId: Int = 0
        public var lottieType: LottieType = .splash1
        public var lottieIdx: Int = 0
        public var isButtonShown: Bool = false
        public var isLoop: Bool = false
        public var isBlackBackground: Bool = false

        public init() { }
    }
    
    public enum Action: Equatable {
        case fetchOnboardingTests(TaskResult<KeymeTestsModel>)
        case nextButtonDidTap
        case lottieEnded
        case startButtonDidTap
        case keymeTests(KeymeTestsFeature.Action)
        
        case succeeded
        case failed
    }
    
    @Dependency(\.keymeTestsClient) var keymeTestsClient
    
    public init() { }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .nextButtonDidTap:
                if state.lottieType == .splash2 {
                    state.isBlackBackground = true
                }
                state.lottieIdx = (state.lottieIdx + 1) % LottieType.allCases.count
                state.lottieType = LottieType.allCases[state.lottieIdx]
                state.isLoop = false
                state.isButtonShown = false
                
            case .lottieEnded:
                if state.lottieType == .splash3 {
                    state.lottieType = .question
                    state.isLoop = true
                    return .run { send in
                        await send(.fetchOnboardingTests(
                            TaskResult { try await self.keymeTestsClient.fetchOnboardingTests() }
                        ))
                    }
                } else {
                    state.isButtonShown = true
                    state.isLoop = true
                }
                
            case let .fetchOnboardingTests(.success(tests)):
                state.testId = tests.testId
                
            case .fetchOnboardingTests(.failure):
                return .none
                
            case .startButtonDidTap:
                let url = "https://keyme-frontend.vercel.app/test/\(state.testId)?nickname=키미"
                state.keymeTests = KeymeTestsFeature.State(url: url)
                
            case .keymeTests:
                return .none
                
            case .succeeded, .failed:
                return .none
                
            }
            
            return .none
        }
        .ifLet(\.keymeTests, action: /Action.keymeTests) {
            KeymeTestsFeature()
        }
    }
}
