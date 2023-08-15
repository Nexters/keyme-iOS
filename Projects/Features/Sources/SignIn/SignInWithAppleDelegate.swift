//
//  SignInWithAppleDelegate.swift
//  Features
//
//  Created by 고도현 on 2023/08/14.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import AuthenticationServices
import Foundation

// FIXME: 추후에 폴더 이동
struct User: Identifiable {
    let id: String
    let email: String
    let name: String
}

class SignInWithAppleDelegate: NSObject, ASAuthorizationControllerDelegate {
    var isLoggedIn = false
    
    // 애플 로그인에 성공했을 때
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
              case let appleIdCredential as ASAuthorizationAppleIDCredential:
                if let _ = appleIdCredential.email, let _ = appleIdCredential.fullName {
                  registerNewUser(credential: appleIdCredential) // 1. 애플 로그인으로 처음 시도했을 때
                } else {
                  signInExistingUser(credential: appleIdCredential) // 2. 기존에 애플 로그인으로 시도한 적이 있을 때
                }
                
              case let passwordCredential as ASPasswordCredential:
                signinWithUserNamePassword(credential: passwordCredential)
                
              default:
                print("[ERROR] 잘못된 접근입니다.")
            }
    }
    
    private func signInWithExistAppleAccount(_ credential: ASAuthorizationAppleIDCredential) {
        print("[ERROR] 애플 로그인에 실패했습니다.")
        
    }
}

// FIXME: API 연결
extension SignInWithAppleDelegate {
    private func registerNewUser(credential: ASAuthorizationAppleIDCredential) {
        // API Call - Pass the email, user full name, user identity provided by Apple and other details.
        // Give Call Back to UI
      }
      
      private func signInExistingUser(credential: ASAuthorizationAppleIDCredential) {
        // API Call - Pass the user identity, authorizationCode and identity token
        // Give Call Back to UI
      }
      
      private func signinWithUserNamePassword(credential: ASPasswordCredential) {
        // API Call - Sign in with Username and password
        // Give Call Back to UI
      }
}
