//
//  SignIn.swift
//  Features
//
//  Created by 이영빈 on 2023/08/10.
//  Edited by 고도 on 2023/08/14.
//
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import AuthenticationServices
import ComposableArchitecture
import Foundation

import KakaoSDKUser
import Network

import SwiftUI

public enum SignInError: Error {
    case noSignIn
}

public struct SignInFeature: Reducer {
    @Dependency(\.keymeAPIManager) var network
    
    public struct State: Equatable {
        @PresentationState var alertState: AlertState<Action.Alert>?
        var isLoading: Bool = false
        var status: Status = .notDetermined
        
        enum Status {
            case notDetermined
            case loggedIn
            case loggedOut
        }
    }
    
    public enum Action: Equatable {
        case signInWithKakao
        case signInWithApple(ASAuthorization)
        
        case signInResponse(TaskResult<AuthDTO>)
        
        case alert(PresentationAction<Alert>)
        case handleError
        public enum Alert: Equatable {}
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            // MARK: - Kakao
            case .signInWithKakao:
                state.isLoading = true
                
                return .run { send in
                    await send(.signInResponse(TaskResult { try await signInWithKakao() }))
                }
                
            // MARK: - Apple
            case .signInWithApple(let authorization):
                state.isLoading = true
                
                guard
                    let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                    let identityTokenData = appleIDCredential.identityToken,
                    let identityToken = String(data: identityTokenData, encoding: .utf8)
                else {
                    return .none
                }
                
                return .run { send in
                    await send(.signInResponse(
                        TaskResult { try await signInWithApple(identityToken: identityToken) }
                    ))
                }
                
            case .signInResponse(.success): // 로그인 성공
                state.isLoading = false
                state.status = .loggedIn
                
                return .none
                
            case .signInResponse(.failure): // 로그인 실패
                state.isLoading = false
                state.status = .loggedOut
                
                return .send(.handleError)
                
            case .handleError:
                state.alertState = .errorWithMessage("로그인 중 에러가 발생했습니다. 잠시 후 다시 시도해주세요.")
                return .none
                
            case .alert:
                return .none
            }
        }
        .ifLet(\.$alertState, action: /Action.alert)
    }
}

extension SignInFeature {
    // 카카오 로그인 메서드
    // Reducer Closure 내부에서 State를 직접 변경할 수 없어서
    // Async - Await를 활용하여 한 번 더 이벤트(signInWithKakaoResponse)를 발생시키도록 구현했습니다.
    private func signInWithKakao() async throws -> AuthDTO {
        let accessToken: String = try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                if (UserApi.isKakaoTalkLoginAvailable()) {
                    UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let oauthToken {
                            continuation.resume(returning: oauthToken.accessToken)
                        } else {
                            continuation.resume(throwing: SignInError.noSignIn)
                        }
                    }
                } else {
                    UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let oauthToken {
                            continuation.resume(returning: oauthToken.accessToken)
                        } else {
                            continuation.resume(throwing: SignInError.noSignIn)
                        }
                    }
                }
            }
        }
        
        return try await network.request(
            .auth(.signIn(oauthType: .kakao, accessToken: accessToken)),
            object: AuthDTO.self)
    }

    // 애플 로그인 메서드
    private func signInWithApple(identityToken: String) async throws -> AuthDTO {
        try await network.request(
            .auth(.signIn(oauthType: .apple, accessToken: identityToken)),
            object: AuthDTO.self)
    }
}
