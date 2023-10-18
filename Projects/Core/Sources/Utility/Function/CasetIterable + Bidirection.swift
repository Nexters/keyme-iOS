//
//  BidirectionalCasetIterable.swift
//  Core
//
//  Created by 이영빈 on 2023/08/11.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

public extension CaseIterable where Self: Equatable, AllCases: BidirectionalCollection {
    /// 이전 `case`를 반환해요
    func previous() -> Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let previous = all.index(before: idx)
        
        if idx == all.startIndex {
            return self
        } else {
            return all[previous]
        }
    }

    /// 다음 `case`를 반환해요
    func next() -> Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let next = all.index(after: idx)
        
        if next == all.endIndex {
            return self
        } else {
            return all[next]
        }
    }
}
