//
//  MyPageFeature.swift
//  Features
//
//  Created by Young Bin on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Core
import ComposableArchitecture
import Domain
import DSKit
import Foundation
import SwiftUI
import Network

public struct MyPageFeature: Reducer {
    @Dependency(\.keymeAPIManager) private var network
    @Dependency(\.shortUrlAPIManager) private var shortURLManager
    
    public struct State: Equatable {
        var view: View
        
        var similarCircleDataList: [CircleData] = []
        var differentCircleDataList: [CircleData] = []
        
        @Box var scoreListState: ScoreListFeature.State
        @PresentationState var settingViewState: SettingFeature.State?
        var imageExportModeState: ImageExportOverlayFeature.State? {
            didSet {
                view.imageExportMode = imageExportModeState == nil ? false : true
            }
        }
        @PresentationState var shareSheetState: ShareSheetFeature.State?
        @PresentationState var alertState: AlertState<Action.Alert>?
        
        struct View: Equatable {            
            let userId: Int
            let nickname: String
            let testId: Int
            var testURL: String { "https://keyme-frontend.vercel.app/test/\(testId)" }
            
            var imageExportMode = false
            
            var circleShown = false
            var selectedSegment: MyPageSegment = .similar
            var shownFirstTime = true
            var shownCircleDatalist: [CircleData] = []
            
            var nowFetching: Bool = false
        }
        
        init(userId: Int, nickname: String, testId: Int) {
            self.view = View(userId: userId, nickname: nickname, testId: testId)
            self._scoreListState = .init(.init())
        }
    }

    public enum Action: Equatable {
        case saveCircle(TaskResult<[CircleData]>, MatchRate)
        case showCircle(MyPageSegment)
        case requestCircle(MatchRate)
        case view(View)
        case showAlert(message: String)
        case showShareSheet(URL)
        
        case scoreListAction(ScoreListFeature.Action)
        case setting(PresentationAction<SettingFeature.Action>)
        case shareSheet(PresentationAction<ShareSheetFeature.Action>)
        case alert(PresentationAction<Action.Alert>)
        case imageExportModeAction(ImageExportOverlayFeature.Action)
 
        public enum View: Equatable {
            case markViewAsShown
            case circleTapped
            case circleDismissed
            case prepareSettingView
            case selectSegement(MyPageSegment)
            case enableImageExportMode
            case captureImage
            case requestTestURL
        }
        
        public enum Alert: Equatable {}
    }
    
    // 마이페이지를 사용할 수 없는 케이스
    // 1. 원 그래프가 아직 집계되지 않음 -> 빈 화면 페이지
    // 2. 네트워크가 연결되지 않음 -> 네트워크 미연결 안내
    public var body: some ReducerOf<Self> {
        Scope(state: \.scoreListState, action: /Action.scoreListAction) {
            ScoreListFeature()
        }
        
        Reduce { state, action in    
            switch action {
            // MARK: - Internal actions
            // 서버 부하가 있으므로 웬만하면 한 번만 콜 할 것
            case .requestCircle(let rate):
                let userId = state.view.userId
                state.view.nowFetching = true

                switch rate {
                case .top5:
                    return .run(priority: .userInitiated) { send in
                        let response = await TaskResult {
                            try await network.request(
                                .myPage(.statistics(userId, .similar)),
                                object: CircleData.NetworkResult.self).toCircleData()
                        }
                        
                        await send(.saveCircle(response, rate))
                    }
                    
                case .low5:
                    return .run(priority: .userInitiated) { send in
                        let response = await TaskResult {
                            try await network.request(
                                .myPage(.statistics(userId, .different)),
                                object: CircleData.NetworkResult.self).toCircleData()
                        }
                        
                        await send(.saveCircle(response, rate))
                    }
                }
                
            case .saveCircle(let taskResult, let rate):
                let data: [CircleData]
                switch taskResult {
                case .success(let received):
                    data = received
                case .failure:
                    state.alertState = AlertState.errorWhileNetworking
                    data = [CircleData]()
                }
                
                switch rate {
                case .top5:
                    state.similarCircleDataList = data
                case .low5:
                    state.differentCircleDataList = data
                }
                
                state.view.nowFetching = false
                return .send(.showCircle(state.view.selectedSegment))
                
            case .showCircle(let segment):
                switch segment {
                case .similar:
                    state.view.shownCircleDatalist = state.similarCircleDataList
                case .different:
                    state.view.shownCircleDatalist = state.differentCircleDataList
                }
                
                return .none
                
            case .showShareSheet(let url):
                state.shareSheetState = ShareSheetFeature.State(url: url)
                
            case .showAlert(let message):
                state.alertState = AlertState.errorWithMessage(message)
                
            // MARK: - View actions
            case .view(.selectSegement(let segment)):
                state.view.selectedSegment = segment
                return .send(.showCircle(state.view.selectedSegment))

            case .view(.markViewAsShown):
                state.view.shownFirstTime = false
                return .none
                
            case .view(.circleTapped):
                HapticManager.shared.tok()
                state.view.circleShown = true
                return .none
                
            case .view(.circleDismissed):
                state.view.circleShown = false
                return .none
                
            case .view(.prepareSettingView):
                print("@@ init from mypage")
                state.settingViewState = SettingFeature.State()
                return .none
                
            case .view(.enableImageExportMode):
                state.imageExportModeState = ImageExportOverlayFeature.State(
                    title: state.view.selectedSegment.title,
                    nickname: state.view.nickname)
                
                return .none
                
            case .view(.requestTestURL):
                return .run { [testURL = state.view.testURL] send in
                    do {
                        
                        let shortURL = try await shortURLManager.request(
                            .shortenURL(longURL: testURL),
                            object: BitlyResponse.self).link
                        
                        guard let url = URL(string: shortURL) else {
                            await send(.showAlert(message: "링크 생성 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요."))
                            return
                        }
                        
                        await send(.showShareSheet(url))
                    } catch {
                        await send(.showAlert(
                            message: "링크 생성 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.\n\(error.localizedDescription)"))
                    }
                }
                
            // MARK: - Child actions
            case .scoreListAction:
                print("score")
                return .none
                
            case .imageExportModeAction(.dismissImageExportMode):
                state.imageExportModeState = nil
                
            case .imageExportModeAction(.captureImage):
                break
                
            case .shareSheet(.dismiss):
                state.shareSheetState = nil
                
            default:
                return .none
            }
            
            return .none
        }
        .ifLet(\.$settingViewState, action: /Action.setting) {
            SettingFeature()
        }
        .ifLet(\.imageExportModeState, action: /Action.imageExportModeAction) {
            ImageExportOverlayFeature()
        }
    }
}

public extension MyPageFeature {
    enum MatchRate {
        case top5
        case low5
    }
    
    struct Coordinate {
        var x: Double
        var y: Double
        var r: Double
        var color: Color
    }
}
