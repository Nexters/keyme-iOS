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
    private let store: StoreOf<SettingFeature>
    
    init(store: StoreOf<SettingFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { _ in
            ZStack {
                DSKitAsset.Color.keymeBlack.swiftUIColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        section(title: "개인정보") {
                            Button(action: {}) {
                                item(text: "로그아웃")
                            }
                            Button(action: {}) {
                                item(text: "서비스 탈퇴")
                            }
                        }
                        
                        Divider()
                        
                        section(title: "마케팅 정보 수신 동의") {
                            HStack {
                                item(text: "푸시 알림")
                                
                                Spacer()
                                
                                Toggle("", isOn: .constant(true))
                            }
                        }
                    }
                    .fullFrame()
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 34)
                    .padding(.top, 40)
                }
            }
        }
    }
}

private extension SettingView {
    func section(title: String, @ViewBuilder items: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            caption(text: title)
                .padding(.bottom, 36)
            
            VStack(alignment: .leading, spacing: 24) {
                items()
            }
        }
    }
    
    func caption(text: String) -> some View {
        Text.keyme(text, font: .body4)
            .foregroundColor(DSKitAsset.Color.keymeMediumgray.swiftUIColor)
    }
    
    func item(text: String) -> some View {
        Text.keyme(text, font: .body2)
            .foregroundColor(DSKitAsset.Color.keymeWhite.swiftUIColor)
    }
}
