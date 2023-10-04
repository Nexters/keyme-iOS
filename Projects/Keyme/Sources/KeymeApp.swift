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
                .onOpenURL(perform: { url in
                    if (AuthApi.isKakaoTalkLoginUrl(url)) {
                        AuthController.handleOpenUrl(url: url)
                    }
                })
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
//    @Dependency(\.notificationManager) var notificationManager
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if let kakaoAPIKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_API_KEY") as? String {
            KakaoSDK.initSDK(appKey: kakaoAPIKey)
        }
        FirebaseApp.configure()

//        Task { await notificationManager.registerPushNotification() }

        return true
    }
}
