//
//  RootFeature+.swift
//  Features
//
//  Created by 이영빈 on 2023/08/25.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Combine
import ComposableArchitecture

import Foundation
import FirebaseCore
import FirebaseMessaging

import UserNotifications
import Network

import SwiftUI

extension RootFeature {
    final class PushNotificationDelegate: NSObject {
        private var fcmToken: String?
        private let tokenSemaphore = DispatchSemaphore(value: 0)

        func waitForToken() async -> String? {
            startRegister()
            
            return await withCheckedContinuation { continuation in
                // If the token has already been received before this method was called
                if let token = self.fcmToken {
                    continuation.resume(returning: token)
                    return
                }
                
                // Wait for the token to be received
                DispatchQueue.global().async {
                    _ = self.tokenSemaphore.wait(timeout: .now() + 20)
                    if let token = self.fcmToken {
                        continuation.resume(returning: token)
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            }
        }
        
        private func startRegister() {
            Messaging.messaging().delegate = self

            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                guard granted else { return }
                
                // 푸시토큰 애플 서버에 등록하기
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    guard settings.authorizationStatus == .authorized else { return }
                    
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
    }
}

extension RootFeature.PushNotificationDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else {
            return
        }
        
        self.fcmToken = token
        tokenSemaphore.signal()
    }
}

extension RootFeature.PushNotificationDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)

        print("firebase Device Token: \(token)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("firebase Failed to register for remote notifications: \(error)")
    }
}
