//
//  KeymeServiceStatusFeature.swift
//  Features
//
//  Created by 이영빈 on 2023/08/10.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

import Domain
import Network
import ComposableArchitecture

public struct KeymeServiceStatusFeature: Reducer {
    private let localStorage: LocalStorage
    
    public init(localStorage: LocalStorage = .shared) {
        self.localStorage = localStorage
    }
    
    public struct State: Equatable {
        @PresentationState public var logInStatus: SignInFeature.State?
        @PresentationState public var onboardingStatus: OnboardingFeature.State?
        
        public init(isLoggedIn: Bool? = nil, doneOnboarding: Bool? = nil) {
            if let isLoggedIn {
                logInStatus = isLoggedIn ? .loggedIn : .loggedOut
            } else {
                logInStatus = .notDetermined
            }
            
            if let doneOnboarding {
                onboardingStatus = doneOnboarding ? .completed : .needsOnboarding
            } else {
                onboardingStatus = .notDetermined
            }
        }
    }
    
    public enum Action: Equatable {
        case login(PresentationAction<SignInFeature.Action>)
        case onboarding(PresentationAction<OnboardingFeature.Action>)
        case mainPage(MainPageFeature.Action)
        
        case checkOnboardingStatus
        case checkLoginStatus
        case onboardingChecked(TaskResult<Bool>)
        case logInChecked(Bool)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .login(.presented(.succeeded)):
                localStorage.set(true, forKey: .isLoggedIn)
                state.logInStatus = .loggedIn
                return .none
                
            case .login(.presented(.failed)):
                localStorage.set(false, forKey: .isLoggedIn)
                state.logInStatus = .loggedOut
                return .none
                
            case .onboarding(.presented(.succeeded)):
                state.onboardingStatus = .completed
                return .none
                
            case .onboarding(.presented(.failed)):
                state.onboardingStatus = .needsOnboarding
                return .none
                
            case .checkLoginStatus:
                let isLoggedIn = localStorage.get(.isLoggedIn) as? Bool ?? false
                return .run { send in
                    await send(.logInChecked(isLoggedIn))
                }
                
            case .checkOnboardingStatus:
                return .run(priority: .userInitiated) { send in
                    await send(.onboardingChecked(
                        TaskResult {
                            // TODO: API 갈아끼우기
                            try await Task.sleep(until: .now + .seconds(3), clock: .continuous)

                            return true
                        }
                    ))
                }
                
            case .logInChecked(true):
                state.logInStatus = .loggedIn
                // logInChecked 결과가 false인 경우는 따로 관리하지 않음
                // 왜냐하면 아무것도 안 건드렸을 때 디폴트가 false이므로
                return .none
            
            case .onboardingChecked(.success(true)):
                state.onboardingStatus = .completed
                return .none
                
            case .onboardingChecked(.success(false)):
                state.onboardingStatus = .needsOnboarding
                return .none
                
            default:
                return .none
            }
        }
        .ifLet(\.$logInStatus, action: /Action.login) {
            SignInFeature()
        }
        .ifLet(\.$onboardingStatus, action: /Action.onboarding) {
            OnboardingFeature()
        }
    }
}
