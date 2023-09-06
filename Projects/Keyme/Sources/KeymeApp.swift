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
                    print(url)
                    if (AuthApi.isKakaoTalkLoginUrl(url)) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    @Dependency(\.notificationManager) var notificationManager
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if let kakaoAPIKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_API_KEY") as? String {
            KakaoSDK.initSDK(appKey: kakaoAPIKey)
        }
        FirebaseApp.configure()

        Task { await notificationManager.registerPushNotification() }
        
        // 웹 뷰 로딩속도 개선 툴
        WKWebViewWarmUper.shared.prepare()

        return true
    }
}
