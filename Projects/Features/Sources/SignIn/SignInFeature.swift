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
import Combine
import ComposableArchitecture
import Foundation
import KakaoSDKUser
import Network

public enum SignInError: Error {
    case noSignIn
}

public struct SignInFeature: Reducer {
    @Dependency(\.localStorage) private var localStorage
    
    private var cancellables = Set<AnyCancellable>()
    
    public enum State: Equatable {
        case notDetermined
        case loggedIn
        case loggedOut
    }
    
    public enum Action: Equatable {
        case signInWithKakao
        case signInWithKakaoResponse(TaskResult<Bool>)
        
        case signInWithApple(AppleOAuthResponse)
        case signInWithAppleResponse(TaskResult<Bool>)
        //        case succeeded
        //        case failed
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .signInWithKakao:
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
                return .none
                
            case .signInWithKakaoResponse(.failure): // 카카오 로그인 실패
                state = .loggedOut
                return .none
                
            case .signInWithApple(let appleOAuth):
                return .run { send in
                    await send(.signInWithAppleResponse(
                        TaskResult {
                            await signInWithApple(appleOAuth)
                        }
                    ))
                }
                
            case .signInWithAppleResponse(.success(true)): // 애플 로그인 성공
                state = .loggedIn
                localStorage.set(true, forKey: .isLoggedIn)
                return .none
                
            case .signInWithAppleResponse(.failure): // 애플 로그인 실패
                state = .loggedOut
                return .none
                
            default:
                state = .loggedOut
            }
            
            return .none
        }
    }
}

extension SignInFeature {
    // 카카오 로그인 메서드
    /// Reducer Closure 내부에서 State를 직접 변경할 수 없어서 Async - Await를 활용하여 한 번 더 이벤트(signInWithKakaoResponse)를 발생시키도록 구현했습니다.
    private func signInWithKakao() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            if (UserApi.isKakaoTalkLoginAvailable()) {
                UserApi.shared.loginWithKakaoTalk { (token, error) in
                    if let error = error {
                        continuation.resume(throwing: SignInError.noSignIn)
                    } else {
                        continuation.resume(returning: true)
                    }
                }
            } else {
                UserApi.shared.loginWithKakaoAccount() { (data, error) in
                    if let error = error {
                        continuation.resume(throwing: SignInError.noSignIn)
                    } else {
                        do {
                            // 1. 카카오 API로 사용자 정보 가져오기
                            let jsonData = try JSONEncoder().encode(data)
                            let parsedData = try JSONDecoder().decode(KakaoOAuthResponse.self, from: jsonData)
                            
                            // 2. Keyme API로 사용자 토큰 확인하기
                            Task {
                                do {
                                    let auth = KeymeOAuthRequest(oauthType: "KAKAO", token: parsedData.accessToken)
                                    let result = try await KeymeAPIManager.shared.request(.auth(param: auth), object: KeymeOAuthResponse.self)
                                    
                                    if result.code == 200 {
                                        return continuation.resume(returning: true)
                                    } else {
                                        return continuation.resume(throwing: SignInError.noSignIn)
                                    }
                                } catch { // 에러가 발생하면 실패 처리
                                    return continuation.resume(throwing: SignInError.noSignIn)
                                }
                            }
                        } catch { // 에러가 발생하면 실패 처리
                            continuation.resume(throwing: SignInError.noSignIn)
                        }
                    }
                }
            }
        }
    }
    
    private func signInWithApple(_ appleOAuth: AppleOAuthResponse) async -> Bool {
        do {
            let auth = KeymeOAuthRequest(oauthType: "APPLE", token: appleOAuth.identifyToken!) // FIXME: 강제 언래핑
            let result = try await KeymeAPIManager.shared.request(.auth(param: auth), object: KeymeOAuthResponse.self)
            
            if result.code == 200 {
                return true
            } else {
                return false
            }
        } catch {
            return false
        }
    }
}
