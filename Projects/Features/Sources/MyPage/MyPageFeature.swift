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
        
        struct View: Equatable {            
            let userId: Int
            let nickname: String
            
            var imageExportMode = false
            
            var circleShown = false
            var selectedSegment: MyPageSegment = .similar
            var shownFirstTime = true
            var shownCircleDatalist: [CircleData] = []
        }
        
        init(userId: Int, nickname: String) {
            self.view = View(userId: userId, nickname: nickname)
            self._scoreListState = .init(.init())
        }
    }

    public enum Action: Equatable {
        case saveCircle([CircleData], MatchRate)
        case showCircle(MyPageSegment)
        case requestCircle(MatchRate)
        case view(View)
        
        case scoreListAction(ScoreListFeature.Action)
        case setting(PresentationAction<SettingFeature.Action>)
        case imageExportModeAction(ImageExportOverlayFeature.Action)
 
        public enum View: Equatable {
            case markViewAsShown
            case circleTapped
            case circleDismissed
            case prepareSettingView
            case selectSegement(MyPageSegment)
            case enableImageExportMode
        }
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

                switch rate {
                case .top5:
                    return .run(priority: .userInitiated) { send in
                        let response = try await network.request(
                            .myPage(.statistics(userId, .similar)),
                            object: CircleData.NetworkResult.self)
                        
                        await send(.saveCircle(response.toCircleData(), rate))
                    }
                    
                case .low5:
                    return .run(priority: .userInitiated) { send in
                        let response = try await network.request(
                            .myPage(.statistics(userId, .different)),
                            object: CircleData.NetworkResult.self)
                        
                        await send(.saveCircle(response.toCircleData(), rate))
                    }
                }
                
            case .saveCircle(let data, let rate):
                switch rate {
                case .top5:
                    state.similarCircleDataList = data
                case .low5:
                    state.differentCircleDataList = data
                }
                
                return .send(.showCircle(state.view.selectedSegment))
                
            case .showCircle(let segment):
                switch segment {
                case .similar:
                    state.view.shownCircleDatalist = state.similarCircleDataList
                case .different:
                    state.view.shownCircleDatalist = state.differentCircleDataList
                }
                return .none
                
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
                
            // MARK: - Child actions
            case .scoreListAction:
                print("score")
                return .none
                
            case .imageExportModeAction(.dismissImageExportMode):
                state.imageExportModeState = nil
                return .none
                
            default:
                return .none
            }
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
