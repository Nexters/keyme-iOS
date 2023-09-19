//
//  CommonAlertState.swift
//  Features
//
//  Created by 이영빈 on 2023/09/13.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation
import ComposableArchitecture

extension AlertState {
    static var errorWhileNetworking: Self {
        AlertState(title: TextState("오류가 발생했어요"), message: TextState("통신 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요"))
    }
    
    static func errorWithMessage(_ message: String) -> Self {
        AlertState(title: TextState("오류가 발생했어요"), message: TextState(message))
    }
    
    static func errorWithMessage(
        _ message: String,
        @ButtonStateBuilder<Action> actions: () -> [ButtonState<Action>]
    ) -> Self {
        AlertState(
            title: { TextState("오류가 발생했어요") },
            actions: actions,
            message: { TextState(message) })
    }
    
    static func information(
        title: String,
        message: String,
        @ButtonStateBuilder<Action> actions: () -> [ButtonState<Action>]
    ) -> Self {
        AlertState(
            title: { TextState(title) },
            actions: actions,
            message: { TextState(message) })
    }
}
