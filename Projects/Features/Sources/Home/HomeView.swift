//
//  HomeView.swift
//  Features
//
//  Created by 이영빈 on 2023/08/30.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

import ComposableArchitecture
import Core
import DSKit
import Domain
import Network

public struct HomeView: View {
    @State var sharedURL: ActivityViewController.SharedURL?
    @State var needToShowProgressView = false
    
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
                        dailyTestListView { questionsStat in
                            viewStore.send(.showScoreList(
                                circleData: CircleData(
                                    color: Color.hex(questionsStat.category.color),
                                    xPoint: 0,
                                    yPoint: 0,
                                    radius: 0.8,
                                    metadata: CircleMetadata(
                                        ownerId: viewStore.userId,
                                        questionId: questionsStat.questionId,
                                        iconURL: URL(string: questionsStat.category.iconUrl),
                                        keyword: questionsStat.keyword,
                                        averageScore: Float(questionsStat.avgScore ?? 0.0),
                                        myScore: 0 // 임시로 채워놓은 값. 구조상 쩔수없음..
                                    )), 
                                questionText: questionsStat.title))
                        }
                        .overlay {
                            LinearGradient(
                                colors: [.black.opacity(0), .black],
                                startPoint: .init(x: 0.5, y: 0.75),
                                endPoint: .bottom)
                            .allowsHitTesting(false)
                        }
                    } else {
                        startTestView
                    }
                    
                    VStack {
                        Spacer()
                        bottomButton(isSolved: isSolvedTest) {
                            HapticManager.shared.boong()
                            
                            @Dependency(\.shortUrlAPIManager) var shortURLAPIManager
                            needToShowProgressView = true
                            
                            if isSolvedTest {
                                let url = CommonVariable.testPageURLString(testId: viewStore.testId)
                                sharedURL = ActivityViewController.SharedURL(url)
                                // API 할당량 넘치면 여기서 응답을 안 주고 막혀버림;; 아나
//                                let shortURL = try await shortURLAPIManager.request(
//                                    .shortenURL(longURL: url),
//                                    object: BitlyResponse.self).link
//
//                                sharedURL = ActivityViewController.SharedURL(shortURL)
                            } else {
                                viewStore.send(.startTest(.presented(.startButtonDidTap)))
                            }
                        }
                    }
                    .padding(.bottom, 26)
                }
            }
            .onAppear {
                if viewStore.isSolvedDailyTest == nil {
                    viewStore.send(.fetchDailyTests)
                }
            }
            .animation(Animation.customInteractiveSpring(), value: viewStore.isSolvedDailyTest)
            .animation(Animation.customInteractiveSpring(), value: needToShowProgressView)
            .fullscreenProgressView(isShown: needToShowProgressView)
        }
        .navigationDestination(
            store: store.scope(
                state: \.$scoreListState,
                action: HomeFeature.Action.circleAndScoreList),
            destination: { CircleAndScoreListView(store: $0) }
        )
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
    
    func dailyTestListView(
        _ onItemTapped: @escaping (QuestionsStatisticsData) -> Void
    ) -> some View {
        let dailyTestListStore = store.scope(
            state: \.$dailyTestListState,
            action: HomeFeature.Action.dailyTestList
        )
        
        return IfLetStore(dailyTestListStore) { store in
            return DailyTestListView(store: store, onItemTapped: onItemTapped)
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
            
            Text.keyme(isSolved ? "테스트 공유하기" : "시작하기", font: .body2)
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
            .onAppear {
                needToShowProgressView = false
            }
        }
    }
}
