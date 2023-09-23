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
    @State var hideButton = false
    
    public var store: StoreOf<HomeFeature>
    
    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0.view }) { viewStore in
            ZStack {
                DSKitAsset.Color.keymeBlack.swiftUIColor.ignoresSafeArea()
                
                if let isSolvedTest = viewStore.isSolvedDailyTest {
                    if isSolvedTest {
                        ScrollView {
                            Spacer().frame(height: 75)
                            
                            dailyTestListView
                            
                            Spacer().frame(height: 60) // 아래 공간 띄우기
                        }
                        .padding(.vertical, 1) // 왜인지는 모르지만 영역 넘치는 문제를 해결해주니 놔둘 것..
                        .refreshable {
                            viewStore.send(.fetchDailyTests)
                        }
                        .simultaneousGesture(
                            DragGesture().onChanged {
                                let isScrollDown = 0 < $0.translation.height
                                if isScrollDown {
                                    self.hideButton = true
                                } else {
                                    self.hideButton = false
                                }
                            })
                    } else {
                        startTestView
                    }
                    
                    VStack {
                        Spacer()
                        
                        if !hideButton {
                            bottomButton(isSolved: isSolvedTest) {
                                @Dependency(\.shortUrlAPIManager) var shortURLAPIManager

                                if isSolvedTest {
                                    let url = "https://keyme-frontend.vercel.app/test/\(viewStore.testId)"
                                    let shortURL = try await shortURLAPIManager.request(
                                        .shortenURL(longURL: url),
                                        object: BitlyResponse.self).link

                                    sharedURL = ActivityViewController.SharedURL(shortURL)
                                } else {
                                    viewStore.send(.startTest(.presented(.startButtonDidTap)))
                                }
                            }
                        }
                    }
                    .padding(.bottom, 26)
                } else {
                    ProgressView()
                }
            }
            .onAppear {
                if viewStore.isSolvedDailyTest == nil {
                    viewStore.send(.fetchDailyTests)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .alert(store: store.scope(state: \.$alertState, action: HomeFeature.Action.alert))
    }
}

extension HomeView {
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
    typealias AsyncThrowClosure = @Sendable () async throws -> Void
    
    // 하단 버튼 (시작하기 / 공유하기)
    func bottomButton(isSolved: Bool, action: @escaping AsyncThrowClosure) -> some View {
        return ZStack {
            Rectangle()
                .cornerRadius(16)
                .foregroundColor(DSKitAsset.Color.keymeWhite.swiftUIColor)

            Text.keyme(isSolved ? "친구에게 공유하기" : "시작하기", font: .body2)
                .foregroundColor(.black)
        }
        .padding(.horizontal, 16)
        .frame(height: 60)
        .onTapGesture {
            Task {
                try await action()
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
