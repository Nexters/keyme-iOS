//
//  SettingFeature.swift
//  Features
//
//  Created by Young Bin on 2023/09/02.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture

import Domain
import Network

public struct SettingFeature: Reducer {
    @Dependency(\.notificationManager) var notificationManager
    @Dependency(\.keymeAPIManager) var network
    
    public struct State: Equatable {
        @PresentationState var alerState: AlertState<Action.Alert>?
        @PresentationState var changeProfileState: RegistrationFeature.State?
        
        var isPushNotificationEnabled: Bool
        
        init() {
            @Dependency(\.notificationManager.isPushNotificationGranted) var isPushNotificationGranted
            self.isPushNotificationEnabled = isPushNotificationGranted
        }
    }
    
    public enum Action: Equatable {
        public enum View: Equatable {
            case changeProfile
            case logout
            case withdrawal
            case togglePushNotification
        }
        
        public enum Alert: Equatable {}
        
        case view(View)
        case alert(Alert)
        case showAlert(message: String)
        case setPushNotificationStatus(Bool)
        
        case changeProfileAction(PresentationAction<RegistrationFeature.Action>)
    }
    
    public init() { }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            // MARK: - View actions
            case .view(.logout):
                return .none
                
            case .view(.withdrawal):
                return .run { send in
                    do {
                        _ = try await network.request(.setting(.withdrawal))
                        await send(.view(.logout))
                    } catch {
                        await send(.showAlert(message: "작업을 실행할 수 없습니다. 잠시 후 다시 시도해주세요."))
                    }
                }
                
            case .view(.togglePushNotification):
                if state.isPushNotificationEnabled == false {
                    // 푸시알림 설정
                    return .run { send in
                        guard await notificationManager.registerPushNotification() != nil else {
                            return
                        }
                        await send(.setPushNotificationStatus(true))
                    }
                } else {
                    // 푸시알림 해제
                    notificationManager.unregisterPushNotification()
                    return .send(.setPushNotificationStatus(false))
                }
                
            case .view(.changeProfile):
                state.changeProfileState = RegistrationFeature.State(isForMyPage: true)
                return .none
                
            // MARK: - Internal actions
            case .showAlert(let message):
                state.alerState = AlertState.errorWithMessage(message)
                
                return .none
                
            // MARK: - Child action
            case .setPushNotificationStatus(let value):
                state.isPushNotificationEnabled = value
                return .none
                
            case .changeProfileAction(.presented(.finishRegisterResponse(let response))):
                let changedNickname = response.data.nickname
                
                state.changeProfileState = nil
                return .none
                
            default:
                return .none
            }
        }
        .ifLet(\.$changeProfileState, action: /Action.changeProfileAction) {
            RegistrationFeature()
        }
    }
}
