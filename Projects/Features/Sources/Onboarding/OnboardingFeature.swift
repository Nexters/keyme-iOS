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
        case needsOnboarding
        case completed
    }
    
    public struct State: Equatable {
        @PresentationState public var keymeTestsState: KeymeTestsFeature.State?
        public var testResultState: TestResultFeature.State?
        public var status: Status = .notDetermined
        
        public var testId: Int = 17 // TODO: 바꾸기
        public var lottieType: LottieType = .splash1
        public var isButtonShown: Bool = false
        public var isLoop: Bool = false
        public var isBlackBackground: Bool = false
        public var isShared: Bool = false

        public init() { }
    }
    
    public enum Action: Equatable {
        case keymeTests(PresentationAction<KeymeTestsFeature.Action>)
        case testResult(TestResultFeature.Action)
        case fetchOnboardingTests(TaskResult<KeymeTestsModel>)
        case nextButtonDidTap
        case lottieEnded
        case startButtonDidTap
        
        case showResult(data: KeymeWebViewModel)
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
                state.lottieType = state.lottieType.next()
                state.isLoop = false
                state.isButtonShown = false
                
            case .lottieEnded:
                if state.lottieType == .splash3 {
                    state.lottieType = .question
                    state.isLoop = true
                    return .run { send in
                        await send(.fetchOnboardingTests(
                            TaskResult { try await self.keymeTestsClient.fetchOnboardingTests()
                            }
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
                // TODO: url 주석단거로 바꾸기
                let url = "https://keyme-frontend.vercel.app/test/\(state.testId)"
//                let url = "https://keyme-frontend.vercel.app/test/5"
                state.keymeTestsState = KeymeTestsFeature.State(url: url)
                
            case .keymeTests(.presented(.showResult(let data))):
                return .send(.showResult(data: data))
                
            case .showResult(data: let data):
                state.testResultState = TestResultFeature.State(
                    testResultId: data.testResultId,
                    testId: state.testId
                )
                
            case .succeeded, .failed:
                return .none
                
            case .keymeTests(.dismiss):
                break
                
            case .testResult(.closeButtonDidTap):
                state.status = .completed
                
            case .keymeTests(.presented(.close)):
                state.keymeTestsState = nil
                
            default:
                break
            }
            
            return .none
        }
        .ifLet(\.$keymeTestsState, action: /Action.keymeTests) {
            KeymeTestsFeature()
        }
        .ifLet(\.testResultState, action: /Action.testResult) {
            TestResultFeature()
        }
    }
}
