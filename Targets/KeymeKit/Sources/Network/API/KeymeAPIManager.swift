//
//  NetworkManager.swift
//  Keyme
//
//  Created by Young Bin on 2023/07/16.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Combine
import CombineMoya
import Moya
import Foundation

public struct KeymeAPIManager: CoreNetworking, APIRequestable {
    var core: CoreNetworkService<KeymeAPI>
    var provider: MoyaProvider<KeymeAPI> {
        core.provider
    }
    let decoder = JSONDecoder()
    
    init(core: CoreNetworkService<KeymeAPI>) {
        self.core = core
    }
}

public extension KeymeAPIManager {
    static let shared = KeymeAPIManager(core: .init())
}
