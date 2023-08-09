import SwiftUI
import SwiftUIIntrospect
import UserNotifications

import ComposableArchitecture
import FirebaseCore
import FirebaseMessaging

import Features

@main
struct KeymeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("isNewbie") private var isNewbie = true
    @State private var selectedTab = 0

    var body: some Scene {
        WindowGroup {
            if isNewbie {
                // 온보딩은 여기에
                Toggle(isOn: $isNewbie) {
                    Text("뉴비세요?")
                }
                .frame(width: 150)
            } else {
                // 온보딩 끝난 후 메인페이지 진입
                TabView(selection: $selectedTab) {
                    TestView(store: Store(
                        initialState: TestStore.State(),
                        reducer: TestStore()))
                    .tabItem {
                        Image(systemName: "1.square.fill")
                        Text("Home")
                    }
                    .tag(0)
                    
                    Text("Tab 2 Content")
                        .tabItem {
                            Image(systemName: "2.square.fill")
                            Text("My page")
                        }
                        .tag(1)
                }
                .introspect(.tabView, on: .iOS(.v16, .v17)) { tabViewController in
                    let tabBar = tabViewController.tabBar
                    
                    let barAppearance = UITabBarAppearance()
                    barAppearance.configureWithOpaqueBackground()
                    barAppearance.backgroundColor = .black
                    
                    let itemAppearance = UITabBarItemAppearance()
                    itemAppearance.selected.iconColor = .white
                    itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
                    itemAppearance.normal.iconColor = .gray
                    itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
                    
                    tabBar.standardAppearance = barAppearance
                    tabBar.standardAppearance.inlineLayoutAppearance = itemAppearance
                    tabBar.standardAppearance.stackedLayoutAppearance = itemAppearance
                    tabBar.standardAppearance.compactInlineLayoutAppearance = itemAppearance
                    tabBar.scrollEdgeAppearance = tabBar.standardAppearance
                }
            }
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
        // Do something
        print(messaging, fcmToken as Any)
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
