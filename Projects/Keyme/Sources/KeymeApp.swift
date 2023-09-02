import SwiftUI
import UserNotifications

import ComposableArchitecture
import FirebaseCore
import FirebaseMessaging

import Features
import Network

import KakaoSDKAuth
import KakaoSDKCommon

@main
struct KeymeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let KAKAO_PRIVATE_KEY = "" // 🚨 SECRET 🚨 
    
    init() {
        KakaoSDK.initSDK(appKey: KAKAO_PRIVATE_KEY)
    }
    
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
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            guard granted else { return }
            
            // 푸시토큰 애플 서버에 등록하기
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                guard settings.authorizationStatus == .authorized else { return }
                
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        return true
    }
    
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
