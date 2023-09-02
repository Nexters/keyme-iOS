//
//  KeymeMainView.swift
//  Keyme
//
//  Created by 이영빈 on 2023/08/09.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import SwiftUIIntrospect
import DSKit
import ComposableArchitecture

struct KeymeMainView: View {
    @State private var selectedTab: Tab = .home
    
    private let store: StoreOf<MainPageFeature>
    
    public init(store: StoreOf<MainPageFeature>) {
        self.store = store
    }
    
    enum Tab: Int {
        case home, myPage
    }
    
    var body: some View {
        NavigationStack {
            WithViewStore(store, observe: { $0 }) { _ in
                TabView(selection: $selectedTab) {
                    KeymeTestsHomeView(store: store.scope(state: \.home, action: MainPageFeature.Action.home))
                        .tabItem {
                            homeTabImage
                        }
                        .tag(Tab.home)
                    
                    MyPageView(store: store.scope(state: \.myPage, action: MainPageFeature.Action.myPage))
                        .tabItem {
                            myPageTabImage
                        }
                        .tag(Tab.myPage)
                }
                .introspect(.tabView, on: .iOS(.v16, .v17)) { tabViewController in
                    let tabBar = tabViewController.tabBar
                    
                    let barAppearance = UITabBarAppearance()
                    barAppearance.configureWithOpaqueBackground()
                    barAppearance.backgroundColor = UIColor(Color.hex("232323"))
                    
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

private extension KeymeMainView {
    var homeTabImage: Image {
        if selectedTab == .home {
            return DSKitAsset.Image.homeSelected.swiftUIImage
        } else {
            return DSKitAsset.Image.home.swiftUIImage
        }
    }
    
    var myPageTabImage: Image {
        if selectedTab == .myPage {
            return DSKitAsset.Image.userSelected.swiftUIImage
        } else {
            return DSKitAsset.Image.user.swiftUIImage
        }
    }
}
