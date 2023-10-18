//
//  TestResultView.swift
//  Features
//
//  Created by 고도현 on 2023/08/18.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

import Core
import DSKit
import Domain
import Network

public struct TestResultView: View {
    @State var sharedURL: ActivityViewController.SharedURL?
    @Dependency(\.shortUrlAPIManager) private var shortURLManager

    private let store: StoreOf<TestResultFeature>
    
    public init(store: StoreOf<TestResultFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                closeButton(viewStore)
                
                Spacer()
                
                resultTitle(viewStore)
                
                Spacer()
                
                resultCardView(viewStore)
                
                Spacer()
                
                indexDisplay(viewStore)
                
                Spacer()
                Spacer()
                
                bottomButton(viewStore)
                
            }
            .background(DSKitAsset.Color.keymeBlack.swiftUIColor)
            .padding(Padding.insets(top: 58, bottom: 54))
            .onAppear {
                viewStore.send(.viewWillAppear)
            }
        }
    }
    
    // 상단 X 버튼
    func closeButton(_ viewStore: ViewStore<TestResultFeature.State, TestResultFeature.Action>) -> some View {
        DSKitAsset.Image.close.swiftUIImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(Padding.insets(trailing: 17))
            .onTapGesture {
                viewStore.send(.closeButtonDidTap(testId: viewStore.testId))
            }
    }
    
    // 결과 확인 텍스트
    func resultTitle(_ viewStore: ViewStore<TestResultFeature.State, TestResultFeature.Action>) -> some View {
        Text.keyme("결과 확인", font: .heading1)
            .foregroundColor(DSKitAsset.Color.keymeWhite.swiftUIColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Padding.insets(leading: 16))
    }
    
    // 결과 확인 카드 뷰
    @MainActor func resultCardView(
        _ viewStore: ViewStore<TestResultFeature.State, TestResultFeature.Action>
    ) -> some View {
        ZStack {
            TabView(selection: viewStore.$testResult) {
                ForEach(viewStore.testResults, id:\.self) {
                    KeymeCardView(nickname: viewStore.nickname, testResult: $0)
                        .tag($0)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
    
    // 결과 확인 카드 하단 인덱스 뷰
    func indexDisplay(_ viewStore: ViewStore<TestResultFeature.State, TestResultFeature.Action>) -> some View {
        HStack(spacing: 4) {
            ForEach(viewStore.testResults, id: \.self) {
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundColor(
                        ($0 == viewStore.testResult) ? .white : .white.opacity(0.3))
            }
        }
        .background(DSKitAsset.Color.keymeBlack.swiftUIColor)
        .padding(.bottom, 12)
    }
    
    // 하단 버튼 (공유하기)
    func bottomButton(_ viewStore: ViewStore<TestResultFeature.State, TestResultFeature.Action>) -> some View {
        ZStack {
            Rectangle()
                .cornerRadius(16)
                .foregroundColor(DSKitAsset.Color.keymeWhite.swiftUIColor)
            
            Text("공유하기")
                .font(Font(DSKitFontFamily.Pretendard.bold.font(size: 18)))
                .foregroundColor(.black)
        }
        .padding(Padding.insets(leading: 16, trailing: 16))
        .frame(height: 60)
        .onTapGesture {
            Task {
                // TODO: url 주석단거로 바꾸기
                let url = "https://keyme-frontend.vercel.app/test/\(17)"
                let shortURL = try await shortURLManager.request(
                    .shortenURL(longURL: url),
                    object: BitlyResponse.self).link
                
                sharedURL = ActivityViewController.SharedURL(shortURL)
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
