//
//  RootFeature.swift
//  Features
//
//  Created by 이영빈 on 2023/09/04.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation
import Domain
import Network
import ComposableArchitecture
import SwiftUI

public struct RootFeature: Reducer {
    @Dependency(\.userStorage) private var userStorage
    @Dependency(\.notificationManager) private var notificationManager
    @Dependency(\.keymeAPIManager) private var network
    
    var authorizationToken: String? {
        @Dependency(\.keymeAPIManager.authorizationToken) var token
        return token
    }
    
    public init() {}
    
    public enum State: Equatable {
        case notDetermined
        case needSignIn(SignInFeature.State)
        case needRegistration(RegistrationFeature.State)
        case needOnboarding(OnboardingFeature.State)
        case canUseApp(MainPageFeature.State)
    }
    
    public enum Action {
        public enum View {
            case checkUserStatus
        }
        case view(View)
        
        case login(SignInFeature.Action)
        case registration(RegistrationFeature.Action)
        case onboarding(OnboardingFeature.Action)
        case mainPage(MainPageFeature.Action)
        
        case updateState(State)
        case updateMemberInformation(withMemberData: MemberUpdateDTO.MemberData?, authorizationToken: String)
        case registerPushNotification
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.checkUserStatus):
                let accessToken = userStorage.accessToken
                if let accessToken { // 로그인 상태
                    network.registerAuthorizationToken(accessToken)
                    return .send(.updateMemberInformation(
                        withMemberData: nil,
                        authorizationToken: accessToken))
                } else { // 로그 아웃 상태
                    return .send(.updateState(.needSignIn(SignInFeature.State())))
                }
                
            case .updateMemberInformation(let receviedMemberData, let accessToken):
                return .run(
                    priority: .userInitiated,
                    operation: { send in
                        let memberInformation: MemberUpdateDTO.MemberData
                        if let receviedMemberData {
                            memberInformation = receviedMemberData
                        } else {
                            memberInformation = try await network.request(
                                .member(.fetch),
                                object: MemberUpdateDTO.self
                            ).data
                        }
                        
                        userStorage.userId = memberInformation.id
                        userStorage.nickname = memberInformation.nickname
                        userStorage.friendCode = memberInformation.friendCode
                        
                        if let profileImageURL = URL(string: memberInformation.profileImage) {
                            userStorage.profileImageURL = profileImageURL
                        }
                        
                        if let profileThumbnailURL = URL(string: memberInformation.profileImage) {
                            userStorage.profileThumbnailURL = profileThumbnailURL
                        }
                        
                        if let userId = memberInformation.id, let nickname = memberInformation.nickname {
                            if memberInformation.isOnboardingClear != true {
                                await send(
                                    .updateState(
                                        .needOnboarding(OnboardingFeature.State(
                                            authorizationToken: accessToken, nickname: nickname))))
                            } else {
                                await send(.updateState(
                                    .canUseApp(MainPageFeature.State(userId: userId, nickname: nickname))))
                            }
                        } else {
                            await send(.updateState(.needRegistration(RegistrationFeature.State())))
                        }
                        
                        await send(.registerPushNotification)
                    },
                    catch: { _, send in
                        // logout
                        userStorage.accessToken = nil
                        await send(.updateState(.needSignIn(SignInFeature.State())))
                    })
                    
            case .updateState(let receivedState):
                state = receivedState
                return .none
                
            case .registerPushNotification:
                Task {
                    guard let token = await notificationManager.registerPushNotification() else {
                        print("푸시토큰 등록 중 에러 발생")
                        return
                    }

                    _ = try await network.request(.registerPushToken(.register(token)))
                }
                
                return .none
                
            // MARK: - Child actions
            case .login(.signInWithAppleResponse(let response)):
                switch response {
                case .success(let body):
                    let token = body.data.token.accessToken
                    userStorage.accessToken = token
                    network.registerAuthorizationToken(token)
                    
                    return .send(.updateMemberInformation(withMemberData: nil, authorizationToken: token))
                    
                case .failure:
                    return logout
                }
                
            case .login(.signInWithKakaoResponse(let response)):
                switch response {
                case .success(let body):
                    let token = body.data.token.accessToken
                    userStorage.accessToken = token
                    network.registerAuthorizationToken(token)
                    
                    return .send(.updateMemberInformation(withMemberData: nil, authorizationToken: token))
                    
                case .failure:
                    return logout
                }
                
            case .registration(.finishRegisterResponse(let response)):
                guard let token = authorizationToken else {
                    // 로그인 재시도
                    return logout
                }
                return .send(.updateMemberInformation(withMemberData: response.data, authorizationToken: token))
                
            case .onboarding(.testResult(.closeButtonDidTap)):
                guard let token = authorizationToken else {
                    // 로그인 재시도
                    return logout
                }
                guard let userId = userStorage.userId, let nickname = userStorage.nickname else {
                    // 멤버 정보 수신 재시도
                    return .send(.updateMemberInformation(withMemberData: nil, authorizationToken: token))
                }
                return .send(.updateState(.canUseApp(MainPageFeature.State(userId: userId, nickname: nickname))))
                
            case .mainPage(.myPage(.setting(.presented(.view(.logout))))):
                return logout
                
            case .mainPage(.home(.requestLogout)):
                return logout
                
            default:
                return .none
            }
        }
        .ifCaseLet(/State.needSignIn, action: /Action.login) {
            SignInFeature()
        }
        .ifCaseLet(/State.needRegistration, action: /Action.registration) {
            RegistrationFeature()
        }
        .ifCaseLet(/State.needOnboarding, action: /Action.onboarding) {
            OnboardingFeature()
        }
        .ifCaseLet(/State.canUseApp, action: /Action.mainPage) {
            MainPageFeature()
        }
    }
    
    private var logout: Effect<RootFeature.Action> {
        userStorage.accessToken = nil
        return .send(.updateState(.needSignIn(SignInFeature.State())))
    }
}
