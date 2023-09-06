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
        case signInWithKakaoResponse(TaskResult<AuthDTO>)
        
        case signInWithApple(ASAuthorization)
        case signInWithAppleResponse(TaskResult<AuthDTO>)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            // MARK: - Kakao
            case .signInWithKakao:
                state.isLoading = true
                
                return .run { send in
                    await send(.signInWithKakaoResponse(TaskResult { try await signInWithKakao() }))
                }
                
            case .signInWithKakaoResponse(.success): // 카카오 로그인 성공
                state.isLoading = false
                state.status = .loggedIn
                return .none
                
            case .signInWithKakaoResponse(.failure): // 카카오 로그인 실패
                state.isLoading = false
                state.status = .loggedOut
                return .none
                
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
                    await send(.signInWithAppleResponse(
                        TaskResult { try await signInWithApple(identityToken: identityToken) }
                    ))
                }
                
            case .signInWithAppleResponse(.success): // 애플 로그인 성공
                state.status = .loggedIn
                return .none
                
            case .signInWithAppleResponse(.failure): // 애플 로그인 실패
                state.status = .loggedOut
                return .none
            }
        }
    }
}

extension SignInFeature {
    // 카카오 로그인 메서드
    /// Reducer Closure 내부에서 State를 직접 변경할 수 없어서 Async - Await를 활용하여 한 번 더 이벤트(signInWithKakaoResponse)를 발생시키도록 구현했습니다.
    // TODO: 나중에 별개의 dependency로 분리할 것(테스트가 안 됨)
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
