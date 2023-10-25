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

import Network

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
            return "환영해요!\n이제 문제를 풀어볼까요?"
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
        @PresentationState public var keymeTestsState: NativeTestFeature.State?
        public var testResultState: TestResultFeature.State?
        public var status: Status = .notDetermined
        
        public var testData: TestData
        public var lottieType: LottieType = .splash1
        public var isButtonShown: Bool = false
        public var isLoop: Bool = false
        public var isBlackBackground: Bool = false
        public var isShared: Bool = false
        
        let authorizationToken: String
        let nickname: String
        public init(authorizationToken: String, nickname: String, testData: TestData) {
            self.authorizationToken = authorizationToken
            self.nickname = nickname
            self.testData = testData
        }
    }
    
    public enum Action: Equatable {
        case keymeTests(PresentationAction<NativeTestFeature.Action>)
        case testResult(TestResultFeature.Action)
        case nextButtonDidTap
        case lottieEnded
        case startButtonDidTap
        
        case showResult(data: TestResult)
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
                state.isButtonShown = true

                if state.lottieType == .splash3 {
                    state.lottieType = .question
                    state.isLoop = true
                } else {
                    state.isLoop = true
                }
                
            case .startButtonDidTap:
                let url = CommonVariable.testPageURLString(testId: state.testData.testId) 
                state.keymeTestsState = NativeTestFeature.State(
                    testId: state.testData.testId,
                    nickname: state.nickname,
                    url: url,
                    authorizationToken: state.authorizationToken,
                    questions: state.testData.questions
                )
                
            case .keymeTests(.presented(.showResult(let data))):
                return .send(.showResult(data: data))
                
            case .showResult(data: let data):
                state.testResultState = TestResultFeature.State(
                    testResultId: data.testResultId,
                    testId: state.testData.testId,
                    nickname: state.nickname
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
            NativeTestFeature()
        }
        .ifLet(\.testResultState, action: /Action.testResult) {
            TestResultFeature()
        }
    }
}
