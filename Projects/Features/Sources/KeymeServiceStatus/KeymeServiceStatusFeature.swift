//
//  KeymeServiceStatusFeature.swift
//  Features
//
//  Created by 이영빈 on 2023/08/10.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation
import Domain
import ComposableArchitecture

public struct KeymeServiceStatusFeature: Reducer {
    private let localStorage: LocalStorage
    
    public init(localStorage: LocalStorage = .shared) {
        self.localStorage = localStorage
    }
    
    public struct State: Equatable {
        @PresentationState public var logInStatus: SignInFeature.State?
        @PresentationState public var onboardingStatus: OnboardingFeature.State?
        
        public init() {
            let isLoggedIn = LocalStorage.shared.get(.isLoggedIn) as? Bool ?? false
            logInStatus = isLoggedIn ? .loggedIn : .loggedOut
            
            let doneOnboarding = LocalStorage.shared.get(.doneOnboarding) as? Bool ?? false
            onboardingStatus = doneOnboarding ? .completed : .needsOnboarding
        }
    }
    
    public enum Action: Equatable {
        case login(PresentationAction<SignInFeature.Action>)
        case onboarding(PresentationAction<OnboardingFeature.Action>)
        case mainPage(MainPageFeature.Action)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .login(.presented(.succeeded)):
                localStorage.set(false, forKey: .isLoggedIn)
                state.logInStatus = .loggedIn
                return .none
                
            case .login(.presented(.failed)):
                localStorage.set(true, forKey: .isLoggedIn)
                state.logInStatus = .loggedOut
                return .none
                
            case .onboarding(.presented(.succeeded)):
                localStorage.set(false, forKey: .doneOnboarding)
                state.onboardingStatus = .completed
                return .none
                
            case .onboarding(.presented(.failed)):
                localStorage.set(true, forKey: .doneOnboarding)
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
