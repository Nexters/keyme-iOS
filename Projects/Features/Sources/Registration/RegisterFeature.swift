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
    
    enum CancelID { case debouncedNicknameUpdate }
    
    public init() {}
    
    public struct State: Equatable {
        @PresentationState var alertState: AlertState<Action.Alert>?

        /// 온보딩에서 쓰는 게 아니라 마이페이지에서 쓸 거라면 `true`를
        var isForMyPage = false
        /// 온보딩에서 쓰는 게 아니라 마이페이지에서 쓸 거라면 `true`를
        
        var status: Status = .notDetermined
        var isNicknameAvailable: Bool?
        var canRegister: Bool {
            return isNicknameAvailable == true
        }

        var thumbnailURL: URL?
        var originalImageURL: URL?
        
        var nicknameTextFieldString: String = ""
        
        enum Status: Equatable {
            case notDetermined
            case needsRegister
            case complete
        }
        
        public init(isForMyPage: Bool = false, nicknamePreset: String? = nil) {
            self.isForMyPage = isForMyPage
            
            if let nicknamePreset {
                nicknameTextFieldString = nicknamePreset
            }
        }
    }
    
    public enum Action: Equatable {
        case debouncedNicknameUpdate(text: String)
        
        case checkDuplicatedNickname(String)
        case checkDuplicatedNicknameResponse(Bool)
        
        case registerProfileImage(Data)
        case registerProfileImageResponse(thumbnailURL: URL, originalImageURL: URL)
        
        case finishRegister(nickname: String, thumbnailURL: URL?, originalImageURL: URL?)
        case finishRegisterResponse(MemberUpdateDTO)
        
        case alert(PresentationAction<Alert>)
        case showAlert
        
        public enum Alert: Equatable {}
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .debouncedNicknameUpdate(let nicknameString):
                guard !nicknameString.isEmpty else {
                    return .none
                }

                state.nicknameTextFieldString = nicknameString
                state.isNicknameAvailable = nil
                
                return .run { send in
                    try await withTaskCancellation(
                        id: CancelID.debouncedNicknameUpdate,
                        cancelInFlight: true
                    ) {
                        try await self.clock.sleep(for: .seconds(0.5))
                        
                        await send(.checkDuplicatedNickname(nicknameString))
                    }
                }
                
            case .checkDuplicatedNickname(let nickname):
                return .run(priority: .userInitiated) { send in
                    let result = try await network.request(
                        .registration(.checkDuplicatedNickname(nickname)),
                        object: VerifyNicknameDTO.self
                    )
                    
                    await send(.checkDuplicatedNicknameResponse(result.data?.valid ?? false))
                }
                
            case .checkDuplicatedNicknameResponse(let isNicknameDuplicated):
                state.isNicknameAvailable = isNicknameDuplicated
                
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
                
            case .finishRegister(let nickname, let thumbnailURL, let originalImageURL):
                return .run { send in
                    let result = try await network.request(
                        .registration(.updateMemberDetails(
                            nickname: nickname,
                            profileImage: thumbnailURL?.absoluteString,
                            profileThumbnail: originalImageURL?.absoluteString)),
                        object: MemberUpdateDTO.self)
                    
                    await send(.finishRegisterResponse(result))
                } catch: { _, send in
                    await send(.showAlert)
                }
                
            case .finishRegisterResponse:
                state.status = .complete

            // MARK: - Child actions:
            case .showAlert:
                state.alertState = .errorWhileNetworking
                
            case .alert:
                return .none
                
            }
            
            return .none
        }
        .ifLet(\.$alertState, action: /Action.alert)
    }
}
