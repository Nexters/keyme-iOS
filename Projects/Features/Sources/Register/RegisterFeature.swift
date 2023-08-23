\//
//  RegisterFeature.swift
//  Features
//
//  Created by 이영빈 on 2023/08/23.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation
import ComposableArchitecture

public struct RegisterFeature: Reducer {
    public enum State: Equatable {
        case notDetermined
        case needsRegister
        case complete
    }
    
    public enum Action: Equatable {
        case registerNickname(String)
        case registerNicknameResponse
        case registerProfileImage(Data)
        case registerProfileImageResponse
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .registerNickname(let nickname):
                return .send(.registerNicknameResponse)
            case .registerProfileImage(let imageData):
                return .send(.registerProfileImageResponse)
            case .registerNicknameResponse:
                break
            case .registerProfileImageResponse:
                break
            }
        }
    }
}
