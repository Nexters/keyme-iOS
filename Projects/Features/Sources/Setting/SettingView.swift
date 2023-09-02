//
//  SettingView.swift
//  Features
//
//  Created by Young Bin on 2023/09/02.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct SettingView: View {
    private let store: StoreOf<SettingFeature>
    
    init(store: StoreOf<SettingFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                Section("개인정보") {
                    Button("로그아웃") {
                        
                    }
                    
                    Button("서비스 탈퇴") {
                        
                    }
                }
                
                Section("마케팅 정보 수신 동의") {
                    
                    HStack {
                        Text("푸시 알림")
                        Spacer()
                        Toggle("", isOn: .constant(true))
                    }
                }
            }
            .listStyle(.inset)
            .background(.red)
        }
    }
}
