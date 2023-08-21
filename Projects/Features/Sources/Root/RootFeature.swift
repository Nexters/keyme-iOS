//
//  RootFeature.swift
//  Features
//
//  Created by 이영빈 on 2023/08/10.
//  Edited by 고도 on 2023/08/14.
// 
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
            onboardingStatus = .init()
            
            if let isLoggedIn {
                logInStatus = isLoggedIn ? .loggedIn : .loggedOut
            } else {
                logInStatus = .notDetermined
            }
            
            if let doneOnboarding {
                onboardingStatus?.status = doneOnboarding ? .completed : .needsOnboarding
            } else {
                onboardingStatus?.status = .notDetermined
            }
        }
    }
    
    public enum Action {
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
//                switch result {
//                case .succeeded:
//                    localStorage.set(true, forKey: .isLoggedIn)
//                    state.logInStatus = .loggedIn
//                case .failed:
//                    localStorage.set(false, forKey: .isLoggedIn)
//                    state.logInStatus = .loggedOut
                return .none
                
            case .onboarding(.presented(let result)):
                switch result {
                case .succeeded:
                    state.onboardingStatus?.status = .completed
                case .failed:
                    state.onboardingStatus?.status = .needsOnboarding
                default:
                    break
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
                    state.onboardingStatus?.status = .completed
                case false:
                    state.onboardingStatus?.status = .needsOnboarding
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
//                            try await Task.sleep(until: .now + .seconds(0.1), clock: .continuous)

                            return false
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
