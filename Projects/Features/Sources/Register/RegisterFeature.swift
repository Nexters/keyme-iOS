//
//  RegisterFeature.swift
//  Features
//
//  Created by 이영빈 on 2023/08/23.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation
import ComposableArchitecture

public struct RegistrationFeature: Reducer {
    @Dependency(\.keymeAPIManager) var network
    
    public struct State: Equatable {
        var status: Status = .notDetermined
        var isNicknameDuplicated: Bool?
        
        enum Status: Equatable {
            case notDetermined
            case needsRegister
            case complete
        }
    }
    
    public enum Action: Equatable {
        case checkDuplicatedNickname(String)
        case checkDuplicatedNicknameResponse(Bool)
        
        case registerProfileImage(Data)
        case registerProfileImageResponse
        
        case finishRegister(String, URL)
        case finishRegisterResponse
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .checkDuplicatedNickname(let nickname):
                return .run(priority: .userInitiated) { send in
                    let result = try await network.request(
                        .registration(.checkDuplicatedNickname(nickname)),
                        object: Bool.self
                    )
                    await send(.checkDuplicatedNicknameResponse(result))
                }
            case .checkDuplicatedNicknameResponse(let isNicknameDuplicated):
                state.isNicknameDuplicated = isNicknameDuplicated
                
            case .registerProfileImage(let imageData):
                return .send(.registerProfileImageResponse)
            case .registerProfileImageResponse:
                break
                
            case .finishRegister(let nickname, let imageURL):
                return .send(.finishRegisterResponse)
            case .finishRegisterResponse:
                break
            }
            
            return .none
        }
    }
}
