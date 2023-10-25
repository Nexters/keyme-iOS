import SwiftUI
import UserNotifications

import Core
import ComposableArchitecture
import FirebaseCore
import FirebaseMessaging

import Features
import Network

import KakaoSDKCommon
import KakaoSDKAuth

@main
struct KeymeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .onOpenURL { url in
                    if (AuthApi.isKakaoTalkLoginUrl(url)) {
                        AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        @Dependency(\.notificationManager) var notificationManager
        
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token {
                notificationManager.passFCMToken(token)
            }
        }
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        @Dependency(\.notificationManager) var notificationManager
        Task { try await notificationManager.registerPushNotification() }
    
        if let kakaoAPIKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_API_KEY") as? String {
            KakaoSDK.initSDK(appKey: kakaoAPIKey)
        }
        
        FirebaseApp.configure()

        return true
    }
}
