//
//  KeymeMainView.swift
//  Keyme
//
//  Created by 이영빈 on 2023/08/09.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import SwiftUIIntrospect
import ComposableArchitecture

struct KeymeMainView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            TestView(store: Store(
                initialState: TestStore.State(),
                reducer: TestStore()))
            .tabItem {
                Image(systemName: "1.square.fill")
                Text("Home")
            }
            .tag(0)
            
            Text("My page content")
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

struct KeymeTabView_Previews: PreviewProvider {
    static var previews: some View {
        KeymeMainView()
    }
}
