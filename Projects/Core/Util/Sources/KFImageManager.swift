//
//  KFImageManager.swift
//  Util
//
//  Created by 김영인 on 2023/08/13.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

import Kingfisher

public final class KFImageManager {
    public static let shared = KFImageManager()
    
    private init() { }
    
    public func toImage(url: String) -> KFImage {
        return KFImage(URL(string: url))
            .placeholder {
                Image(systemName: "questionmark.circle.fill")
            }
            .retry(maxCount: 3, interval: .seconds(3))
            .onFailure { error in print("Kingfisher Error: \(error)") }
            .resizable()
    }
}
