//
//  NotificationManager.swift
//  Core
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

public final class NotificationManager: NSObject {
    public private(set) var isPushNotificationGranted: Bool = false
    private let userNotificationCenter = UNUserNotificationCenter.current()
    
    private var application: UIApplication?
    
    private var fcmToken: String?
    private let tokenSemaphore = DispatchSemaphore(value: 0)
    
    func setApplication(_ application: UIApplication) {
        self.application = application
    }
    
    /// 쓰레드 블로킹이라 웬만하면 비동기로 처리하세요. 까딱하다 앱 작살남
    func registerPushNotification() async -> String? {
        guard let application else {
            print("UIApplication 등록하고 쓰세요! (푸시알림 매니저 올림)")
            return nil
        }
        
        userNotificationCenter.delegate = self
        do {
            isPushNotificationGranted = try await userNotificationCenter.requestAuthorization(
                options: [.alert, .badge, .sound])
            
            guard isPushNotificationGranted else {
                return nil
            }
            
            // 푸시토큰 애플 서버에 등록하기
            let settings = await userNotificationCenter.notificationSettings()
            guard settings.authorizationStatus == .authorized else {
                isPushNotificationGranted = false
                return nil
            }
            
            return await waitForToken(for: application)
        } catch {
            return nil
        }
    }
    
    func unregisterPushNotification() {
        guard let application else {
            print("UIApplication 등록하고 쓰세요! (푸시알림 매니저 올림)")
            return
        }
        
        DispatchQueue.main.async {
            application.unregisterForRemoteNotifications()
        }
    }

    private func waitForToken(for application: UIApplication) async -> String? {
        Messaging.messaging().delegate = self
        
        DispatchQueue.main.async {
            application.registerForRemoteNotifications()
        }
        
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

extension NotificationManager: UNUserNotificationCenterDelegate {
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

extension NotificationManager: MessagingDelegate {
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else {
            return
        }
        
        self.fcmToken = token
        tokenSemaphore.signal()
    }
}

extension NotificationManager: DependencyKey {
    public static var liveValue = NotificationManager()
}

extension DependencyValues {
    var notificationManager: NotificationManager {
        get { self[NotificationManager.self] }
        set { self[NotificationManager.self] = newValue }
    }
}
