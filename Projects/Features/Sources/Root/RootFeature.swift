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
        @PresentationState public var onboardingState: OnboardingFeature.State?
        @PresentationState public var mainPageState: MainPageFeature.State?
        
        var userStatus: UserStatus = .notDetermined
        
        public enum UserStatus: Equatable {
            case notDetermined
            case needSignIn
            case needRegistration
            case needOnboarding
            case canUseApp(userId: Int, nickname: String)
        }
    }
    
    public enum Action {
        public enum View {
            case checkUserStatus
        }
        case view(View)
        
        case login(PresentationAction<SignInFeature.Action>)
        case registration(PresentationAction<RegistrationFeature.Action>)
        case onboarding(PresentationAction<OnboardingFeature.Action>)
        case mainPage(PresentationAction<MainPageFeature.Action>)
        
        case updateState(State.UserStatus)
        case updateMemberInformation(withMemberData: MemberUpdateDTO.MemberData?)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.checkUserStatus):
                let accessToken = userStorage.accessToken
                if accessToken == nil { // 로그 아웃 상태
                    return .send(.updateState(.needSignIn))
                } else { // 로그인 상태
                    network.registerAuthorizationToken(accessToken)
                    return .send(.updateMemberInformation(withMemberData: nil))
                }
        
            case .updateMemberInformation(let receviedMemberData):
                return .run(priority: .userInitiated) { send in
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
                    
                    if let friendCode = memberInformation.friendCode {
                        userStorage.friendCode = friendCode
                    }
                    
                    if let profileImageURL = URL(string: memberInformation.profileImage) {
                        userStorage.profileImageURL = profileImageURL
                    }
                    
                    if let profileThumbnailURL = URL(string: memberInformation.profileImage) {
                        userStorage.profileThumbnailURL = profileThumbnailURL
                    }
                    
                    if memberInformation.nickname == nil {
                        await send(.updateState(.needRegistration))
                    } else if memberInformation.isOnboardingClear == false {
                        await send(.updateState(.needOnboarding))
                    } else {
                        await send(.updateState(.canUseApp(userId: memberInformation.id, nickname: memberInformation.nickname)))
                    }
                    
                    Task.detached(priority: .low) {
                        let notificationDelegate = UserNotificationCenterDelegateManager()
                        
                        guard let token = await notificationDelegate.waitForToken() else {
                            print("푸시토큰 등록 중 에러 발생")
                            return
                        }
                        
                        _ = try await network.request(.registerPushToken(.register(token)))
                    }
                }
                
            case .updateState(let status):
                state.userStatus = status
                
                switch status {
                case .notDetermined:
                    break
                case .needSignIn:
                    state.logInStatus = .loggedIn
                case .needRegistration:
                    state.registrationState = .init()
                case .needOnboarding:
                    state.onboardingState = .init()
                case let .canUseApp(userId, nickname):
                    state.mainPageState = .init(userId: userId, nickname: nickname)
                }
                
                return .none
                
            // MARK: - Presentation actions
            case .login(.presented(.signInWithAppleResponse(let response))):
                switch response {
                case .success(let body):
                    let token = body.data.token.accessToken
                    userStorage.accessToken = token
                    network.registerAuthorizationToken(token)
                    
                    return .send(.updateMemberInformation(withMemberData: nil))
                    
                case .failure:
                    return .none
                }
                
            case .login(.presented(.signInWithKakaoResponse(let response))):
                switch response {
                case .success(let body):
                    let token = body.data.token.accessToken
                    userStorage.accessToken = token
                    network.registerAuthorizationToken(token)
                    
                    return .send(.updateMemberInformation(withMemberData: nil))

                case .failure:
                    return .none
                }
                
            case .registration(.presented(.finishRegisterResponse(let response))):
                return .send(.updateMemberInformation(withMemberData: response.data))
                
            case .onboarding(.presented(.testResult(.closeButtonDidTap))):
                guard let userId = userStorage.userId, let nickname = userStorage.nickname else {
                    // 멤버 정보 수신 재시도
                    // TODO: and show alert. 사실 있을 수 없는 케이스긴 함
                    return .send(.updateMemberInformation(withMemberData: nil))
                }
                
                return .send(.updateState(.canUseApp(userId: userId, nickname: nickname)))
                
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
        .ifLet(\.$onboardingState, action: /Action.onboarding) {
            OnboardingFeature()
        }
        .ifLet(\.$mainPageState, action: /Action.mainPage) {
            MainPageFeature()
        }
    }
}

private extension RootFeature {
    func needsRegistration(forNickname nickname: String?) -> Bool {
        if nickname == nil {
            return true
        } else {
            return false
        }
    }
}
