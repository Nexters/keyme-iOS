//
//  SignInView.swift
//  Keyme
//
//  Created by 이영빈 on 2023/08/10.
//  Edited by 고도 on 2023/08/14.
//
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import AuthenticationServices
import Core
import ComposableArchitecture
import DSKit
import SwiftUI
import Network

public struct SignInView: View {
    private let store: StoreOf<SignInFeature>
    
    public init(store: StoreOf<SignInFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack(alignment: .center) {
            Text.keyme("KEYME", font: .checkResult)
                .foregroundColor(.white)
                .offset(y: -39)
            
            VStack(alignment: .center, spacing: 30) {
                Spacer()
                
                VStack(spacing: 16) {
                    KakaoLoginButton(store: store)
                        .frame(height: 48)
                    
                    AppleLoginButton(store: store)
                        .frame(height: 48)
                }
                
                GuideMessageView()
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 56)
        }
    }
    
    // 카카오 로그인 버튼
    struct KakaoLoginButton: View {
        let store: StoreOf<SignInFeature>
        
        var body: some View {
            Button(action: {
                store.send(.signInWithKakao)
                HapticManager.shared.boong()
            }) {
                Image("kakao_login")
                    .resizable()
                    .scaledToFill()
            }
            .cornerRadius(6)
        }
    }
    
    // 애플 로그인 버튼
    struct AppleLoginButton: View {
        let store: StoreOf<SignInFeature>
        
        var body: some View {
            SignInWithAppleButton(
                onRequest: { request in
                    HapticManager.shared.boong()
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { completion in
                    switch completion {
                    case .success(let appleOAuth):
                        store.send(.signInWithApple(appleOAuth))
                    case .failure:
                        store.send(.signInWithAppleResponse(.failure(SignInError.noSignIn)))
                    }
                })
            .signInWithAppleButtonStyle(.white)
            .cornerRadius(6)
        }
    }
    
    struct GuideMessageView: View {
        var body: some View {
            VStack(spacing: 8) {
                Text("가입 시, 키미의 다음 사항에 동의하는 것으로 간주합니다.")
                    .foregroundColor(.gray)
                
                HStack(spacing: 4) {
                    Button(action: {}) {
                        Text("서비스 이용약관")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Text("및")
                        .foregroundColor(.gray)
                    
                    Button(action: {}) {
                        Text("개인정보 정책")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .foregroundColor(.white)
                }
            }
            .font(.system(size: 11))
        }
    }
}
