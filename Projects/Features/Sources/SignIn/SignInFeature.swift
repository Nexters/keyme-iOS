//
//  SignIn.swift
//  Features
//
//  Created by 이영빈 on 2023/08/10.
//  Edited by 고도 on 2023/08/14.
//
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation
import ComposableArchitecture
import KakaoSDKUser

public struct SignInFeature: Reducer {
    @Dependency(\.localStorage) private var localStorage
    
    public enum SignInError: Error {
        case noSignIn
    }
    
    public enum State: Equatable {
        case notDetermined
        case loggedIn
        case loggedOut
    }
    
    public enum Action: Equatable {
        case signIn
        case signInWithKakaoResponse(TaskResult<Bool>)
//        case succeeded
//        case failed
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .signIn:
                return .run { send in
                    await send(.signInWithKakaoResponse(
                        TaskResult {
                            try await signInWithKakao()
                        }
                    ))
                }
            case .signInWithKakaoResponse(.success(true)): // 카카오 로그인 성공
                state = .loggedIn
                localStorage.set(true, forKey: .isLoggedIn)
            case .signInWithKakaoResponse(.failure): // 카카오 로그인 실패
                state = .loggedOut
            default:
                state = .loggedOut
            }
            return .none
        }
    }
    
    // FIXME: 토큰 검증 로직 추가
    // 카카오 로그인 메서드
    /// Reducer Closure 내부에서 State를 직접 변경할 수 없어서 Async - Await를 활용하여 한 번 더 이벤트(signInWithKakaoResponse)를 발생시키도록 구현했습니다.
    private func signInWithKakao() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            if (UserApi.isKakaoTalkLoginAvailable()) {
                UserApi.shared.loginWithKakaoTalk { (_, error) in
                    if let error = error {
                        continuation.resume(throwing: SignInError.noSignIn)
                    } else {
                        continuation.resume(returning: true)
                    }
                }
            } else {
                UserApi.shared.loginWithKakaoAccount() { (_, error) in
                    if let error = error {
                        continuation.resume(throwing: SignInError.noSignIn)
                    } else {
                        continuation.resume(returning: true)
                    }
                }
            }
        }
    }
}
