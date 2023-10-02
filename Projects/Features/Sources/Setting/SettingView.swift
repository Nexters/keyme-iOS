//
//  SettingView.swift
//  Features
//
//  Created by Young Bin on 2023/09/02.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture
import DSKit
import SwiftUI
import SwiftUIIntrospect

struct SettingView: View {
    @State private var showAlert = false
    @State private var alertItem: AlertItem?
    
    private let store: StoreOf<SettingFeature>
    
    init(store: StoreOf<SettingFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }, send: SettingFeature.Action.view) { viewStore in
            ZStack {
                DSKitAsset.Color.keymeBlack.swiftUIColor
                    .ignoresSafeArea()
                    
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        section(title: "개인정보") {
                            logoutButton(action: { viewStore.send(.logout) })
                            withdrawlButton(action: { viewStore.send(.withdrawal) })
                        }

                        Divider()
                        
                        section(title: "마케팅 정보 수신 동의") {
                            pushNotificationToggleButton(
                                isOn: viewStore.binding(
                                    get: \.isPushNotificationEnabled,
                                    send: .togglePushNotification))
                        }
                    }
                    .fullFrame()
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 34)
                    .padding(.top, 40)
                }
                .addCommonNavigationBar()
                .alert("앗!", isPresented: $showAlert, presenting: alertItem) { item in
                    Button("취소", role: .cancel) { }
                    Button(item.actionButtonName) { item.action() }
                } message: { item in
                    Text(item.message)
                }
            }
        }
    }
}

private extension SettingView {
    func logoutButton(action: @escaping () -> Void) -> some View {
        Button(action: {
            showAlert = true
            alertItem = AlertItem(
                message: "정말 로그아웃 하시겠어요?",
                actionButtonName: "로그아웃",
                action: action
            )
        }) {
            item(text: "로그아웃").frame(minWidth: 0, maxWidth: .infinity)
        }
    }
    
    func withdrawlButton(action: @escaping () -> Void) -> some View {
        Button(action: {
            showAlert = true
            alertItem = AlertItem(
                message: "탈퇴 시 모든 정보가 삭제됩니다. 정말 탈퇴하시겠어요?",
                actionButtonName: "회원탈퇴",
                action: action
            )
        }) {
            item(text: "서비스 탈퇴").frame(minWidth: 0, maxWidth: .infinity)
        }
    }
    
    func pushNotificationToggleButton(isOn binding: Binding<Bool>) -> some View {
        HStack {
            item(text: "푸시 알림")
            
            Spacer()
            
            Toggle("", isOn: binding)
        }
    }
    
    func section(title: String, @ViewBuilder items: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            caption(text: title)
                .padding(.bottom, 24)
            
            VStack(alignment: .leading, spacing: 0) {
                items()
            }
            .frame(minWidth: 0, maxWidth: .infinity)
        }
    }
    
    func caption(text: String) -> some View {
        Text.keyme(text, font: .body4)
            .foregroundColor(DSKitAsset.Color.keymeMediumgray.swiftUIColor)
    }
    
    func item(text: String) -> some View {
        HStack {
            Text.keyme(text, font: .body2)
                .foregroundColor(DSKitAsset.Color.keymeWhite.swiftUIColor)
            Spacer()
        }
        .padding(.vertical, 12)
    }
}

private struct AlertItem {
    let message: String
    let actionButtonName: String
    let action: () -> Void
}
