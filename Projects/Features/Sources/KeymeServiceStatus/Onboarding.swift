//
//  Onboarding.swift
//  Features
//
//  Created by 이영빈 on 2023/08/10.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation
import ComposableArchitecture

public struct OnboardingFeature: Reducer {
    public enum State: Equatable {
        case completed
        case needsOnboarding
    }
    public enum Action: Equatable {
        case succeeded
        case failed
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}
