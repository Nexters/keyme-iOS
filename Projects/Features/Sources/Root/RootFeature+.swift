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
    final class UserNotificationCenterDelegateManager: NSObject {
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
                    _ = self.tokenSemaphore.wait(timeout: .now() + 10)
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
        }
    }
}

extension RootFeature.UserNotificationCenterDelegateManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else {
            return
        }
        
        self.fcmToken = token
        tokenSemaphore.signal()
    }
}

extension SwitchingRootFeature {
    final class UserNotificationCenterDelegateManager: NSObject {
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
                    _ = self.tokenSemaphore.wait(timeout: .now() + 10)
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
        }
    }
}

extension SwitchingRootFeature.UserNotificationCenterDelegateManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else {
            return
        }
        
        self.fcmToken = token
        tokenSemaphore.signal()
    }
}
