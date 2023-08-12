//
//  String+.swift
//  Util
//
//  Created by 김영인 on 2023/08/13.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

import Kingfisher

public extension String {
    
    /**
     Description: url 문자열 받아 Image 리턴하는 함수
     */
    func toImage() -> KFImage {
        let url = URL(string: self)
        return KFImage(url)
            .placeholder {
                Image(systemName: "x.circle.fill")
            }
            .retry(maxCount: 3, interval: .seconds(3))
            .onSuccess { success in print("success: \(success)") }
            .onFailure { error in print("failure: \(error)") }
            .resizable()
    }
}
