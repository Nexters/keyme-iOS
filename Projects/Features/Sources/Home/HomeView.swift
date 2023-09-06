//
//  HomeView.swift
//  Features
//
//  Created by 이영빈 on 2023/08/30.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

import ComposableArchitecture

import DSKit
import Domain
import Network

public struct HomeView: View {
    @State var sharedURL: ActivityViewController.SharedURL?
    
    public var store: StoreOf<HomeFeature>
    
    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0.view }) { viewStore in
            ZStack(alignment: .center) {
                DSKitAsset.Color.keymeBlack.swiftUIColor.ignoresSafeArea()
                
                VStack {
                    if(viewStore.isSolvedDailyTest) {
                        dailyTestListView
                    } else {
                        startTestView
                    }
                    
                    Spacer()
                    
                    bottomButton(viewStore)
                    
                    Spacer()
                        .frame(height: 26)
                }
            }
            .onAppear {
                if viewStore.dailyTestId == nil {
                    viewStore.send(.fetchDailyTests)
                }
            }
        }
        .alert(store: store.scope(state: \.$alertState, action: HomeFeature.Action.alert))
    }
}

extension HomeView {
    //
    var startTestView: some View {
        let startTestStore = store.scope(
            state: \.$startTestState,
            action: HomeFeature.Action.startTest
        )
        
        return IfLetStore(startTestStore) { store in
            StartTestView(store: store)
        } else: {
            Circle()
                .strokeBorder(.white.opacity(0.3), lineWidth: 1)
                .background(Circle().foregroundColor(.white.opacity(0.3)))
                .frame(width: 280 * 0.8, height: 280 * 0.8)
        }
    }
    
    // 데일리
    var dailyTestListView: some View {
        let dailyTestListStore = store.scope(
            state: \.$dailyTestListState,
            action: HomeFeature.Action.dailyTestList
        )
        
        return IfLetStore(dailyTestListStore) { store in
            DailyTestListView(store: store)
        }
    }
}

extension HomeView {
    // 하단 버튼 (시작하기 / 공유하기)
    func bottomButton(_ viewStore: ViewStore<HomeFeature.State.View, HomeFeature.Action>) -> some View {
        ZStack {
            Rectangle()
                .cornerRadius(16)
                .foregroundColor(DSKitAsset.Color.keymeWhite.swiftUIColor)

            Text(viewStore.isSolvedDailyTest ? "친구에게 공유하기" : "시작하기")
                .font(Font(DSKitFontFamily.Pretendard.bold.font(size: 18)))
                .foregroundColor(.black)
        }
        .padding([.leading, .trailing], 16)
        .frame(height: 60)
        .onTapGesture {
            Task {
                // TODO: 현재 url 이슈로 shorURL 생성 안됨 -> 추후에 바꿔놓기
                if viewStore.isSolvedDailyTest {
                    let url = "https://keyme-frontend.vercel.app/test/17"
                    //                let url = "https://keyme-frontend.vercel.app/test/\(viewStore.view.testId)"
//                    let shortURL = try await ShortUrlAPIManager.shared.request(
//                        .shortenURL(longURL: url),
//                        object: BitlyResponse.self).link

                    sharedURL = ActivityViewController.SharedURL("www.example.com")
                } else {
                    // TODO: 시작하기 누르면 웹뷰로 가도록 구현
                }
            }
        }
        .sheet(item: $sharedURL) { item in
            ActivityViewController(
                isPresented: Binding<Bool>(
                    get: { sharedURL != nil },
                    set: { if !$0 { sharedURL = nil } }),
                activityItems: [item.sharedURL])
        }
    }
}
