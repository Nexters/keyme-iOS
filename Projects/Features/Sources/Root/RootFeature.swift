//
//  RootFeature.swift
//  Features
//
//  Created by 이영빈 on 2023/08/10.
//  Edited by 고도 on 2023/08/14.
// 
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

import Domain
import Network
import ComposableArchitecture

public struct RootFeature: Reducer {
    @Dependency(\.userStorage) private var userStorage
    @Dependency(\.keymeAPIManager) private var network
    
    public init() {}
    
    public struct State: Equatable {
        @PresentationState public var logInStatus: SignInFeature.State?
        @PresentationState public var registrationState: RegistrationFeature.State?
        @PresentationState public var onboardingStatus: OnboardingFeature.State?
        
        public init(
            isLoggedIn: Bool? = nil,
            doneRegistration: Bool? = nil,
            doneOnboarding: Bool? = nil
        ) {
            registrationState = .init()
            onboardingStatus = .init()
            
            if let isLoggedIn {
                logInStatus = isLoggedIn ? .loggedIn : .loggedOut
            } else {
                logInStatus = .notDetermined
            }
            
            if let doneRegistration {
                registrationState?.status = doneRegistration ? .complete : .needsRegister
            } else {
                registrationState?.status = .notDetermined
            }
            
            if let doneOnboarding {
                onboardingStatus?.status = doneOnboarding ? .completed : .needsOnboarding
            } else {
                onboardingStatus?.status = .notDetermined
            }
        }
    }
    
    public enum Action {
        case login(PresentationAction<SignInFeature.Action>)
        case registration(PresentationAction<RegistrationFeature.Action>)
        case onboarding(PresentationAction<OnboardingFeature.Action>)
        case mainPage(MainPageFeature.Action)
        
        case onboardingChecked(TaskResult<Bool>)
                
        case checkLoginStatus
        case checkRegistrationStatus
        case checkOnboardingStatus
        
        case updateMemberInformation
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .login(.presented(.signInWithAppleResponse(let response))):
                switch response {
                case .success(let body):
                    let token = body.data.token.accessToken
                    userStorage.accessToken = token
                    network.registerAuthorizationToken(token)
                    
                    if body.data.nickname == nil {
                        state.registrationState?.status = .needsRegister
                    } else {
                        state.registrationState?.status = .complete
                    }
                    return .none
                    
                case .failure:
                    return .none
                }
                
            case .login(.presented(.signInWithKakaoResponse(let response))):
                switch response {
                case .success(let body):
                    let token = body.data.token.accessToken
                    userStorage.accessToken = token
                    network.registerAuthorizationToken(token)
                    
                    if body.data.nickname == nil {
                        state.registrationState?.status = .needsRegister
                    } else {
                        state.registrationState?.status = .complete
                    }
                    return .none
                    
                case .failure:
                    return .none
                }
                
            case .checkLoginStatus:
                let accessToken = userStorage.accessToken
                if accessToken == nil {
                    state.logInStatus = .loggedOut
                } else {
                    state.logInStatus = .loggedIn
                    network.registerAuthorizationToken(accessToken)
                }
                
                return .none
                
            case .registration(.presented(.finishRegisterResponse)):
                // Do nothing currently
                return .none
                
            case .checkRegistrationStatus:
                let nickname: String? = userStorage.nickname
                
                if nickname == nil {
                    state.registrationState?.status = .needsRegister
                } else {
                    state.registrationState?.status = .complete
                }
                
                return .none
                
            case .checkOnboardingStatus:
                return .run(priority: .userInitiated) { send in
                    await send(.onboardingChecked(
                        TaskResult {
                            // TODO: API 갈아끼우기
//                            try await Task.sleep(until: .now + .seconds(0.1), clock: .continuous)
                            return false
                        }
                    ))
                }
                
            case .onboardingChecked(.success(let result)):
                switch result {
                case true:
                    state.onboardingStatus?.status = .completed
                    // 온보딩 체크 끝나면 서버에 API 쳐서 유저 데이터 업데이트
                    // 온보딩 체크는 앱 켜질 떄마다 될 거고 이게 사실상 앱 진입 전 마지막 과정이라서 여기서 업뎃
                    return .send(.updateMemberInformation)
                    
                case false:
                    state.onboardingStatus?.status = .needsOnboarding
                }
                return .none
                
            case .updateMemberInformation:
                return .run(priority: .userInitiated) { _ in
                    let memberInformation = try await network.request(
                        .member(.fetch),
                        object: MemberUpdateDTO.self).data
                    
                    userStorage.nickname = memberInformation.nickname
                    
                    if let profileImageURL = URL(string: memberInformation.profileImage) {
                        userStorage.profileImageURL = profileImageURL
                    }
                    
                    if let profileThumbnailURL = URL(string: memberInformation.profileImage) {
                        userStorage.profileThumbnailURL = profileThumbnailURL
                    }
                    
                    Task.detached(priority: .low) {
                        let notificationDelegate = UserNotificationCenterDelegateManager()
                        guard let token = await notificationDelegate.waitForToken() else {
                            print("ERROR TOEKN PUSH")
                            return
                        }
                        
                        _ = try await network.request(.registerPushToken(.register(token)))
                    }
                }
                
            default:
                return .none
            }
        }
        .ifLet(\.$logInStatus, action: /Action.login) {
            SignInFeature()
        }
        .ifLet(\.$registrationState, action: /Action.registration) {
            RegistrationFeature()
        }
        .ifLet(\.$onboardingStatus, action: /Action.onboarding) {
            OnboardingFeature()
        }
    }
}
