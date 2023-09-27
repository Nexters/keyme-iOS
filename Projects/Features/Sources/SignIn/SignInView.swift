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
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.isLoading {
                CustomProgressView()
            }
            
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
            .alert(store: store.scope(state: \.$alertState, action: SignInFeature.Action.alert))
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
                        store.send(.signInResponse(.failure(SignInError.noSignIn)))
                    }
                })
            .signInWithAppleButtonStyle(.white)
            .cornerRadius(6)
        }
    }
    
    struct GuideMessageView: View {
        let serviceTermURLString = "https://keyme.notion.site/Keyme-b1f3902d8fe04b97be6d8835119887cd?pvs=4"
        let privacyTermURLString = "https://keyme.notion.site/Keyme-46bef61be1204fc594a49e85e5913a39?pvs=4"
        
        var body: some View {
            VStack(spacing: 8) {
                Text("가입 시, 키미의 다음 사항에 동의하는 것으로 간주합니다.")
                    .foregroundColor(.gray)
                
                HStack(spacing: 4) {
                    Button(action: {
                        guard let serviceTermURL = URL(string: serviceTermURLString) else {
                            return
                        }
                        UIApplication.shared.open(serviceTermURL)
                    }) {
                        Text("서비스 이용약관")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Text("및")
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        guard let privacyTermURL = URL(string: privacyTermURLString) else {
                            return
                        }
                        UIApplication.shared.open(privacyTermURL)
                    }) {
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
