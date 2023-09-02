//
//  SettingFeature.swift
//  Features
//
//  Created by Young Bin on 2023/09/02.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture

import Domain
import Network

public struct SettingFeature: Reducer {
    
    public struct State: Equatable {}
    
    public enum Action: Equatable {
        case logout
        case withdrawal
        case setPushNotification
    }
    
    public init() { }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .logout:
                return .none
            case .withdrawal:
                // TODO: Call api
                return .none
            case .setPushNotification:
                return .none
            }
        }
    }
}
