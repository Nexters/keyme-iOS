//
//  RegisterFeature.swift
//  Features
//
//  Created by 이영빈 on 2023/08/23.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation
import ComposableArchitecture
import Network

public struct RegistrationFeature: Reducer {
    @Dependency(\.keymeAPIManager) var network
    @Dependency(\.continuousClock) var clock
    
    enum CancelID { case checkNickname }
    
    public init() {}
    
    public struct State: Equatable {
        var status: Status = .notDetermined
        var isNicknameDuplicated: Bool?

        var thumbnailURL: URL?
        var originalImageURL: URL?
        
        var nicknameTextFieldString: String = ""
        
        enum Status: Equatable {
            case notDetermined
            case needsRegister
            case complete
        }
    }
    
    public enum Action: Equatable {
        case debouncedNicknameUpdate(text: String)
        
        case checkDuplicatedNickname(String)
        case checkDuplicatedNicknameResponse(Bool)
        
        case registerProfileImage(Data)
        case registerProfileImageResponse(thumbnailURL: URL, originalImageURL: URL)
        
        case finishRegister(nickname: String, thumbnailURL: URL, originalImageURL: URL)
        case finishRegisterResponse(id: Int, friendCode: String)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .debouncedNicknameUpdate(let nicknameString):
                state.nicknameTextFieldString = nicknameString
                return .run { send in
                    try await withTaskCancellation(
                        id: CancelID.checkNickname,
                        cancelInFlight: true
                    ) {
                        try await self.clock.sleep(for: .seconds(0.7))
                        
                        await send(.checkDuplicatedNickname(nicknameString))
                    }
                }
                
            // MARK: checkDuplicatedNickname
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
                
            // MARK: registerProfileImage
            case .registerProfileImage(let imageData):
                return .run { send in
                    let result = try await network.request(
                        .registration(.uploadImage(imageData)),
                        object: ImageUploadDTO.self)
                    
                    if
                        let thumbnailURL = URL(string: result.data.thumbnailUrl),
                        let originalImageURL = URL(string: result.data.originalUrl)
                    {
                        await send(
                            .registerProfileImageResponse(
                                thumbnailURL: thumbnailURL,
                                originalImageURL: originalImageURL))
                    }
                }
                
            case .registerProfileImageResponse(let thumnailURL, let originalImageURL):
                state.thumbnailURL = thumnailURL
                state.originalImageURL = originalImageURL
                
            // MARK: finishRegister
            case .finishRegister(let nickname, let thumbnailURL, let originalImageURL):
                return .run { send in
                    let result = try await network.request(
                        .registration(.updateMemberDetails(
                            nickname: nickname,
                            profileImage: thumbnailURL.absoluteString,
                            profileThumbnail: originalImageURL.absoluteString)),
                        object: MemberUpdateDTO.self)
                    
                    await send(
                        .finishRegisterResponse(
                            id: result.data.id,
                            friendCode: result.data.friendCode))
                }
                
            case .finishRegisterResponse:
                state.status = .complete
            }
            
            return .none
        }
    }
}
