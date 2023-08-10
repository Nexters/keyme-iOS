//
//  KeymeServiceStatusFeature.swift
//  Features
//
//  Created by 이영빈 on 2023/08/10.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation
import ComposableArchitecture

public struct KeymeServiceStatusFeature: Reducer {
    public init() {}
    
    public struct State: Equatable {
        @PresentationState public var logInStatus: SignInFeature.State?
        @PresentationState public var onboardingStatus: OnboardingFeature.State?
        
        public init() {
            // FIXME: 나중에 얘는 어떻게 뺄 것
            let needsSignIn = UserDefaults.standard.object(forKey: "needsSignIn") as? Bool ?? true
            logInStatus = needsSignIn ? .loggedOut : .loggedIn
            
            let needsOnboardling = UserDefaults.standard.object(forKey: "needsOnboardling") as? Bool ?? true
            onboardingStatus = needsOnboardling ? .needsOnboarding : .completed
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
                UserDefaults.standard.set(false, forKey: "needsSignIn")
                state.logInStatus = .loggedIn
                return .none
                
            case .login(.presented(.failed)):
                UserDefaults.standard.set(true, forKey: "needsSignIn")
                state.logInStatus = .loggedOut
                return .none
                
            case .onboarding(.presented(.succeeded)):
                UserDefaults.standard.set(false, forKey: "needsOnboardling")
                state.onboardingStatus = .completed
                return .none
                
            case .onboarding(.presented(.failed)):
                UserDefaults.standard.set(true, forKey: "needsOnboardling")
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
