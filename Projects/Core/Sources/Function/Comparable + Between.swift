//
//  Between.swift
//  Core
//
//  Created by 이영빈 on 2023/08/11.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

extension Comparable {
    /// `min` 과  `max` 사이의 값만  반환해줘요.
    func between(min minValue: Self, max maxValue: Self) -> Self {
        min(maxValue, max(minValue, self))
    }
}
