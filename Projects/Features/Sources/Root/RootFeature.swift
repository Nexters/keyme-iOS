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
                        
                        let isOnboardingClear = memberInformation.isOnboardingClear ?? false
                        if let userId = memberInformation.id, let nickname = memberInformation.nickname {
                            if isOnboardingClear == false {
                                await send(
                                    .updateState(
                                        .needOnboarding(OnboardingFeature.State(
                                            authorizationToken: accessToken,
                                            nickname: nickname,
                                            testData: try await onboardingTest))))
                            } else {
                                // 온보딩 진행한 유저로서 메인페이지 이동
                                await send(
                                    .updateState(
                                        .canUseApp(
                                            MainPageFeature.State(
                                                userId: userId,
                                                testId: try await onboardingTestId,
                                                nickname: nickname, 
                                                needsToShowGuideView: false))))
                            }
                        } else {
                            await send(.updateState(.needRegistration(RegistrationFeature.State())))
                        }
                    },
                    catch: { _, send in
                        // logout
                        userStorage.accessToken = nil
                        await send(.updateState(.needSignIn(SignInFeature.State())))
                    })
                    
            case .updateState(let receivedState):
                state = receivedState
                return .none
                
            // MARK: - Child actions
            case .login(.signInResponse(let response)):
                switch response {
                case .success(let body):
                    let token = body.data.token.accessToken
                    userStorage.accessToken = token
                    network.registerAuthorizationToken(token)
                    
                    return .send(.updateMemberInformation(withMemberData: nil, authorizationToken: token))
                    
                case .failure:
                    // 하위 뷰에서 다루게 두기
                    return .none
                }
                
            case .registration(.finishRegisterResponse(let response)):
                guard let token = authorizationToken else {
                    // 로그인 재시도
                    return logout
                }
                return .send(.updateMemberInformation(withMemberData: response.data, authorizationToken: token))
                
            case .onboarding(.testResult(.closeButtonDidTap(let testId))):
                guard let token = authorizationToken else {
                    // 로그인 재시도
                    return logout
                }
                guard let userId = userStorage.userId, let nickname = userStorage.nickname else {
                    // 멤버 정보 수신 재시도
                    return .send(.updateMemberInformation(withMemberData: nil, authorizationToken: token))
                }
                
                // 온보딩 진행하지 않았떤 유저로서 메인페이지 이동
                return .send(
                    .updateState(
                        .canUseApp(
                            MainPageFeature.State(
                                userId: userId, testId: testId, nickname: nickname, needsToShowGuideView: true))))
                
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
}

private extension RootFeature {
    var logout: Effect<RootFeature.Action> {
        userStorage.accessToken = nil
        return .send(.updateState(.needSignIn(SignInFeature.State())))
    }
    
    var onboardingTest: TestData {
        get async throws {
            let testIdObject = try await network.request(.test(.onboarding), object: KeymeTestsDTO.self)
            return testIdObject.data
        }
    }
    
    var onboardingTestId: Int {
        get async throws {
            let testIdObject = try await network.request(.test(.onboarding), object: KeymeTestsDTO.self)
            return testIdObject.data.testId
        }
    }
    
    var dailyTestId: Int {
        get async throws {
            let testIdObject = try await network.request(.test(.daily), object: KeymeTestsDTO.self)
            return testIdObject.data.testId
        }
    }
}
