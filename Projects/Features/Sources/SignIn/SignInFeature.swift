//
//  SignIn.swift
//  Features
//
//  Created by 이영빈 on 2023/08/10.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation
import ComposableArchitecture

public struct SignInFeature: Reducer {
    public enum State: Equatable {
        case notDetermined
        case loggedIn
        case loggedOut
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
