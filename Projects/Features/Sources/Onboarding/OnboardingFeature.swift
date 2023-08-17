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
    //    public enum State: Equatable {
    //        case notDetermined
    //        case completed
    //        case needsOnboarding
    //    }
    
    public struct State: Equatable {
        public var lottieType: LottieType = .splash1
        public var lottieIdx: Int = 0
        public var isButtonShown: Bool = false
        public var isLoop: Bool = false
        public var isBlackBackground: Bool = false
        
        public init() { }
    }
    
    public enum Action: Equatable {
        case nextButtonDidTap
        case lottieEnded
        
        case succeeded
        case failed
    }
    
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
                } else {
                    state.isButtonShown = true
                }
                state.isLoop = true
            case .succeeded, .failed:
                return .none
            }
            return .none
        }
    }
}
