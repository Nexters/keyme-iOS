//
//  RootFeature.swift
//  Features
//
//  Created by 이영빈 on 2023/08/10.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

import Domain
import Network
import ComposableArchitecture

public struct RootFeature: Reducer {
    @Dependency(\.localStorage) private var localStorage
    
    public init() {}
    
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
        
        case onboardingChecked(TaskResult<Bool>)
        case logInChecked(Bool)
        
        case checkOnboardingStatus
        case checkLoginStatus
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .login(.presented(let result)):
                switch result {
                case .succeeded:
                    localStorage.set(true, forKey: .isLoggedIn)
                    state.logInStatus = .loggedIn
                case .failed:
                    localStorage.set(false, forKey: .isLoggedIn)
                    state.logInStatus = .loggedOut
                }
                return .none
                
            case .onboarding(.presented(let result)):
                switch result {
                case .succeeded:
                    state.onboardingStatus = .completed
                case .failed:
                    state.onboardingStatus = .needsOnboarding
                }
                return .none
                
            case .logInChecked(let result):
                switch result {
                case true:
                    state.logInStatus = .loggedIn
                case false:
                    state.logInStatus = .loggedOut
                }
                return .none
                
            case .onboardingChecked(.success(let result)):
                switch result {
                case true:
                    state.onboardingStatus = .completed
                case false:
                    state.onboardingStatus = .needsOnboarding
                }
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