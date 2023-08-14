//
//  SignInView.swift
//  Keyme
//
//  Created by 이영빈 on 2023/08/10.
//  Edited by 고도 on 2023/08/14.
//
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

public struct SignInView: View {
    private let store: StoreOf<SignInFeature>
    
    public init(store: StoreOf<SignInFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
            
            KakaoLoginButton(store: store)
            
            AppleLoginButton()
            
            GuideMessageView()
        }
        .padding()
    }
    
    // 카카오 로그인 버튼
    struct KakaoLoginButton: View {
        let store: StoreOf<SignInFeature>
        
        var body: some View {
            Button(action: {
                store.send(.signIn)
            }) {
                Image("kakao_login")
                    .resizable()
                    .scaledToFill()
            }
            .frame(width: 312, height: 48)
            .cornerRadius(6)
        }
    }
    
    // 애플 로그인 버튼
    struct AppleLoginButton: View {
        var body: some View {
            Button(action: { }) { // FIXME: API 추가
                Image("apple_login_white")
                    .resizable()
                    .scaledToFill()
            }
            .frame(width: 312, height: 48)
            .cornerRadius(6)
            .padding(.vertical)
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
            .frame(width: 265, height: 36)
        }
    }
}
