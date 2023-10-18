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
    @Dependency(\.keymeAPIManager) var network
    
    public var isPushNotificationGranted: Bool {
        userStorage.pushNotificationEnabled ?? true
    }
    
    private let userNotificationCenter = UNUserNotificationCenter.current()
    private let application: UIApplication = .shared
    
    private var fcmToken: String?
    private var isRegistrationInProgress: Bool = false
    private var tokenSemaphore = DispatchSemaphore(value: 0)
    
    override init() {
        super.init()
        
        if isPushNotificationGranted {
            Task { try await registerPushNotification() }
        }
    }
    
    /// 쓰레드 블로킹이라 웬만하면 비동기로 처리하세요. 까딱하다 앱 작살남
    public func registerPushNotification() async throws {
        guard isRegistrationInProgress == false else {
            return
        }
        
        userNotificationCenter.delegate = self
        isRegistrationInProgress = true
        defer {
            isRegistrationInProgress = false
        }

        do {
            try await userNotificationCenter.requestAuthorization(options: [.alert, .badge, .sound])

            // 푸시토큰 애플 서버에 등록하기
            let settings = await userNotificationCenter.notificationSettings()
            guard settings.authorizationStatus == .authorized else {
                userStorage.pushNotificationEnabled = false
                return
            }
            
            await application.registerForRemoteNotifications()

            // FCM 토큰 올 때까지 쓰레드 막고 기다리고 있을 것임
            guard let fcmToken = await waitForToken(for: application) else {
                userStorage.pushNotificationEnabled = false
                return
            }
            
            userStorage.pushNotificationEnabled = true
            try await registerPushTokenToKeymeServer(with: fcmToken)
            print("[KEYME]: Push notification is registered with FCM token \(fcmToken)")
        } catch {
            userStorage.pushNotificationEnabled = false
        }
    }
    
    public func unregisterPushNotification() async {
        await application.unregisterForRemoteNotifications()
        
        userStorage.pushNotificationEnabled = false
        tokenSemaphore = DispatchSemaphore(value: 0)
        fcmToken = nil
        
        if let fcmToken {
            try? await unregisterPushTokenToKeymeServer(with: fcmToken)
        }
    }
    
    public func passFCMToken(_ token: String) {
        self.fcmToken = token
        tokenSemaphore.signal()
    }

    // MARK: - Private
    private func registerPushTokenToKeymeServer(with token: String) async throws {
        _ = try await network.request(.pushToken(.register(token)))
    }
    
    private func unregisterPushTokenToKeymeServer(with token: String) async throws {
        _ = try await network.request(.pushToken(.delete(token)))
    }
    
    private func waitForToken(for application: UIApplication) async -> String? {
        return await withCheckedContinuation { continuation in
            // If the token has already been received before this method was called
            if let token = self.fcmToken {
                continuation.resume(returning: token)
                return
            }
            
            // Wait for the token to be received
            DispatchQueue.global(qos: .utility).async {
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

extension PushNotificationManager: DependencyKey {
    public static var liveValue = PushNotificationManager()
}

extension DependencyValues {
    public var notificationManager: PushNotificationManager {
        get { self[PushNotificationManager.self] }
        set { self[PushNotificationManager.self] = newValue }
    }
}
