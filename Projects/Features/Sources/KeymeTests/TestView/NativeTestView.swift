//
//  NativeTestView.swift
//  Features
//
//  Created by ab180 on 10/19/23.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import Core
import ComposableArchitecture
import DSKit
import Domain
import Network

public struct QuestionWithScore: Equatable {
    let question: Question
    var score: Int?
}

public struct NativeTestFeature: Reducer {
    public struct State: Equatable {
        let testId: Int
        let nickname: String
        let url: String
        let authorizationToken: String
        let questions: [Question]
        
        var questionsWithScore: [QuestionWithScore]
        var needToShowProgress: Bool = false
        
        @PresentationState var alertState: AlertState<Action.Alert>?
        
        public init(
            testId: Int,
            nickname: String,
            url: String,
            authorizationToken: String,
            questions: [Question]
        ) {
            self.testId = testId
            self.nickname = nickname
            self.url = url
            self.authorizationToken = authorizationToken
            self.questions = questions
            
            self.questionsWithScore = questions.map { QuestionWithScore(question: $0) }
            self.alertState = alertState
        }
    }
    
    public enum Action: Equatable {
        case transition
        case close
        
        case submit(resultCode: String, testResultId: Int)
        case showResult(TestResult)
        
        case view(View)
        case alert(PresentationAction<Alert>)
        
        case showProgress(enabled: Bool)
        case showErrorAlert(message: String)
        
        public enum View: Equatable {
            case resetQuestionResponses
            case postResult
            case closeButtonTapped
            case closeWebView
            case recordScore(ofQuestionIndex: Int, score: Int)
        }
        
        public enum Alert: Equatable {
            case closeTest
        }
    }
    
    @Dependency(\.keymeTestsClient) var keymeTestsClient
    @Dependency(\.keymeAPIManager) var network
    
    public init() { }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .transition:
                return .none
                
            case .close:
                return .none
                
                // MARK: - View actions
            case .view(.resetQuestionResponses):
                state.questionsWithScore = state.questions.map { QuestionWithScore(question: $0) }

            case .view(.closeButtonTapped):
                state.alertState = AlertState.information(title: "", message: "테스트를 종료하시겠어요?", actions: {
                    ButtonState(
                        role: .cancel,
                        label: { TextState("취소") }
                    )
                    ButtonState(
                        action: .closeTest,
                        label: { TextState("종료") }
                    )
                })
                
            case .view(.postResult):
                state.needToShowProgress = true
                
                return .run { [state] send in
                    do {
                        let response = try await self.network.request(
                            .test(.submit(
                                testId: state.testId,
                                state.questionsWithScore.map { ($0.question.questionId, $0.score ?? 3) })),
                            object: SubmitResponseDTO.self)
                        
                        await send(.showResult(response.data))
                        await send(.showProgress(enabled: false))
                    } catch {
                        await send(.showErrorAlert(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요."))
                        await send(.showProgress(enabled: false))
                    }
                }
                
            case .view(.closeWebView):
                return .send(.close)
                
            case .view(.recordScore(let questionIndex, let score)):
                state.questionsWithScore[questionIndex].score = score
                
            case .submit:
                return .none
                
            case .showProgress(let enabled):
                state.needToShowProgress = enabled
                return .none
                
            case .showErrorAlert(let message):
                state.needToShowProgress = false
                state.alertState = AlertState.errorWithMessage(message)
                
            case .alert(.presented(.closeTest)):
                return .send(.close)
                
            default:
                return .none
            }
            
            return .none
        }
        .ifLet(\.$alertState, action: /Action.alert)
    }
}

public struct NativeTestView: View {
    @State var categoryIndex = 0
    @State var showNextCircle = false
    @State var showPreviousCircle = false
    
    let store: StoreOf<NativeTestFeature>
    
    public init(store: StoreOf<NativeTestFeature>) {
        self.store = store
    }
    
    public var body: some View {
        let baseWidthRatio = 0.9
        
        return WithViewStore(store, observe: { $0 }, send: NativeTestFeature.Action.view) { viewStore in
            var questions: [Question] { viewStore.questions }
            var isLastQuestion: Bool { categoryIndex == questions.endIndex - 1 }
            var isFirstQuestion: Bool { categoryIndex == 0 }
            
            GeometryReader { proxy in
                ZStack {
                    DSKitAsset.Color.keymeBlack.swiftUIColor
                        .ignoresSafeArea()
                    
                    VStack(alignment: .center, spacing: 0) {
                        progressBarView(
                            width: proxy.size.width * baseWidthRatio,
                            currentIndex: categoryIndex,
                            totalCount: questions.count)
                        .zIndex(2)
                        
                        Spacer()
                        
                        backMenuBar {
                            if isFirstQuestion {
                                // 테스트 종료
                                viewStore.send(.closeButtonTapped)
                                viewStore.send(.resetQuestionResponses)
                            } else {
                                showPreviousCircle = true
                            }
                        }
                        
                        Spacer()
                        
                        NativeTestContentView(
                            nickname: viewStore.nickname,
                            questions: questions,
                            questionIndex: $categoryIndex,
                            showNextCircle: $showNextCircle,
                            showPreviousCircle: $showPreviousCircle
                        ) { index, score in
                            viewStore.send(.recordScore(ofQuestionIndex: index, score: score))
                        }
                        .padding(.horizontal, 18)
                        .zIndex(1)
                        
                        Spacer()
                        
                        CTAButton(textLabel: isLastQuestion ? "완료" : "다음") {
                            HapticManager.shared.boong()
                            
                            if isLastQuestion {
                                viewStore.send(.postResult)
                            } else {
                                showNextCircle = true
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.bottom, 20)
                        .zIndex(2)
                    }
                    
                }
                .toolbar(.hidden, for: .navigationBar)
                .alert(store: store.scope(state: \.$alertState, action: NativeTestFeature.Action.alert))
            }
            .fullscreenProgressView(isShown: viewStore.needToShowProgress)
        }
        .transition(.opacity.animation(Animation.customInteractiveSpring(duration: 1)))
    }
}

private extension NativeTestView {
    typealias Action = () -> Void
    
    func progressBarView(
        width: CGFloat,
        currentIndex: Int,
        totalCount: Int,
        spacing: CGFloat = 1.8
    ) -> some View {
        let individualBarWidth = (width - spacing * CGFloat(totalCount - 1)) / CGFloat(totalCount)
        
        return HStack(spacing: spacing) {
            ForEach(0..<totalCount, id: \.self) { position in
                RoundedRectangle(cornerRadius: 3)
                    .foregroundColor(.white.opacity(position <= currentIndex ? 1 : 0.3))
                    .frame(width: individualBarWidth, height: 2)
            }
        }
    }
    
    func backMenuBar(onTapAction: @escaping Action) -> some View {
        HStack {
            Button(action: onTapAction) {
                Image(systemName: "chevron.left")
                    .resizable()
                    .frame(width: 10, height: 20)
                    .scaledToFit()
                    .foregroundColor(.white)
                    .padding(.vertical, 5)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .background(.clear)
    }
    
    func CTAButton(textLabel: String, onTapAction: @escaping Action) -> some View {
        Button(action: onTapAction) {
            RoundedRectangle(cornerRadius: 16)
                .frame(height: 60)
                .overlay {
                    Text.keyme(textLabel, font: .body2)
                        .foregroundColor(.black)
                }
        }
        .foregroundColor(.white)
    }
}
