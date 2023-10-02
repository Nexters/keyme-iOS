//
//  MainPageFeature.swift
//  Features
//
//  Created by 이영빈 on 2023/08/10.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation
import StoreKit
import ComposableArchitecture
import Core

public final class EnvironmentVariable {
    var userId: Int!
    var nickname: String!
}

extension EnvironmentVariable: DependencyKey {
    public static var liveValue = EnvironmentVariable()
}

extension DependencyValues {
    public var environmentVariable: EnvironmentVariable {
        get { self[EnvironmentVariable.self] }
        set { self[EnvironmentVariable.self] = newValue }
    }
}

public struct MainPageFeature: Reducer {
    public struct State: Equatable {
        var testId: Int?
        
        @Box var home: HomeFeature.State
        @Box var myPage: MyPageFeature.State
        @PresentationState var onboardingGuideState: OnboardingGuideFeature.State?
        
        var view: View = .none
        enum View: Equatable { case none }
        
        public init(userId: Int, testId: Int, nickname: String) {
            @Dependency(\.environmentVariable) var environmentVariable
            @Dependency(\.userStorage) var userStorage
            let currentLaunchCount = userStorage.launchCount ?? 0 // 실행한 적 없으면 nil == 0
            
            environmentVariable.userId = userId
            environmentVariable.nickname = nickname
            
            self._home = .init(.init(userId: userId, nickname: nickname, testId: testId))
            self._myPage = .init(.init(userId: userId, nickname: nickname, testId: testId))
            
            print("[KEYME] Keyme launched \(currentLaunchCount) times")
            if currentLaunchCount == 0 {
                onboardingGuideState = OnboardingGuideFeature.State()
            } else if currentLaunchCount == 3 {
                // Request review
                requestReview()
            }
            
            userStorage.launchCount = currentLaunchCount + 1
        }
        
        /// 앱스토어 리뷰 요청하는 뷰 띄우기
        private func requestReview() {
            DispatchQueue.main.async {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: windowScene)
                }
            }
        }
    }
    
    public enum Action {
        case home(HomeFeature.Action)
        case myPage(MyPageFeature.Action)
        case onboardingGuide(PresentationAction<OnboardingGuideFeature.Action>)
        case getTestId
    }
    
    public var body: some Reducer<State, Action> {
        Scope(state: \.home, action: /Action.home) {
            HomeFeature()
        }
        
        Scope(state: \.myPage, action: /Action.myPage) {
            MyPageFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .getTestId:
                guard state.testId == nil else {
                    return .none
                }
                
//                testId =
                
            case .onboardingGuide(.presented(.dismiss)):
                state.onboardingGuideState = nil
                
            default:
                break
            }
            
            return .none
        }
        .ifLet(\.$onboardingGuideState, action: /Action.onboardingGuide) {
            OnboardingGuideFeature()
        }
    }
}
