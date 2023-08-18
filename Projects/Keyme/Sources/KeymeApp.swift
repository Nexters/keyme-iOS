import SwiftUI
import UserNotifications

import ComposableArchitecture
import FirebaseCore
import FirebaseMessaging

import Features
import Network

@main
struct KeymeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        KeymeAPIManager.shared.registerAuthorizationToken(
            "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhY2Nlc3NUb2tlbiIsImlhdCI6MTY5MTg0MjM1NiwiZXhwIjoxNjk0NDM0MzU2LCJtZW1iZXJJZCI6Miwicm9sZSI6IlJPTEVfVVNFUiJ9.bLUl_ObvXr2pkLGNBZYWbJgLZLo3P0xB2pawckRGYZM"
        )

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            guard granted else { return }
            
            // 푸시토큰 애플 서버에 등록하기
            self.getNotificationSettings()
        }
        return true
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else {
            return
        }
        
        Task {
            try await KeymeAPIManager.shared.request(.registerPushToken(fcmToken))
        }
    }
}

extension AppDelegate {
    private func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}
