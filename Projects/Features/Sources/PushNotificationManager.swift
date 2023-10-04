//
//  PushNotificationManager.swift
//  Feature
//
//  Created by 이영빈 on 2023/09/04.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture
import Foundation
import SwiftUI

import FirebaseCore
import FirebaseMessaging

import UserNotifications
import Network

public final class PushNotificationManager: NSObject {
    @Dependency(\.userStorage) var userStorage
    
    public var isPushNotificationGranted: Bool {
        userStorage.pushNotificationEnabled ?? true
    }
    private let userNotificationCenter = UNUserNotificationCenter.current()
    private var application: UIApplication = .shared
    
    private var fcmToken: String?
    private let tokenSemaphore = DispatchSemaphore(value: 0)
    
    override init() {
        super.init()
        
        if isPushNotificationGranted {
            Task { await registerPushNotification() }
        }
    }
    
    /// 쓰레드 블로킹이라 웬만하면 비동기로 처리하세요. 까딱하다 앱 작살남
    public func registerPushNotification() async -> String? {
        print("@@ reg called")
        userNotificationCenter.delegate = self
        Messaging.messaging().delegate = self

        do {
            try await userNotificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
            
            // 푸시토큰 애플 서버에 등록하기
            let settings = await userNotificationCenter.notificationSettings()
            guard settings.authorizationStatus == .authorized else {
                userStorage.pushNotificationEnabled = false
                return nil
            }
            
            guard let result = await waitForToken(for: application) else {
                userStorage.pushNotificationEnabled = false
                return nil
            }
            
            userStorage.pushNotificationEnabled = true
            return result
        } catch {
            userStorage.pushNotificationEnabled = false
            print("@@", error)
            return nil
        }
    }
    
    public func unregisterPushNotification() {
        DispatchQueue.main.async {
            self.application.unregisterForRemoteNotifications()
            self.userStorage.pushNotificationEnabled = false
        }
    }

    private func waitForToken(for application: UIApplication) async -> String? {
        await application.registerForRemoteNotifications()
        
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
}

extension PushNotificationManager: UNUserNotificationCenterDelegate {}

extension PushNotificationManager: MessagingDelegate {
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else {
            return
        }
        
        self.fcmToken = token
        tokenSemaphore.signal()
    }
}

extension PushNotificationManager: DependencyKey {
    public static var liveValue = PushNotificationManager()
}

extension DependencyValues {
    public var notificationManager: PushNotificationManager {
        get { self[PushNotificationManager.self] }
        set { self[PushNotificationManager.self] = newValue }
    }
}
