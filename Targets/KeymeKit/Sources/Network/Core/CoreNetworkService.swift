//
//  CoreNetworkService.swift
//  Keyme
//
//  Created by Young Bin on 2023/07/18.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Moya
import Foundation

struct CoreNetworkService<APIType: TargetType>: CoreNetworking {
    private(set) var provider: MoyaProvider<APIType>
    
    init(provider: MoyaProvider<APIType> = .init()) {
        self.provider = provider
    }
    
    @discardableResult
    mutating func registerAuthorizationToken(_ authorizationToken: String) -> Self {
        let newProvider = MoyaProvider<APIType>(endpointClosure: endpointClosure(with: authorizationToken))
        provider = newProvider
        
        return CoreNetworkService(provider: newProvider)
    }
}

private extension CoreNetworkService {
    func endpointClosure(with token: String) -> MoyaProvider<APIType>.EndpointClosure {
        return { (target: APIType) -> Endpoint in
            let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)

            switch target {
            default:
                return defaultEndpoint.adding(newHTTPHeaderFields: ["Authorization": token])
            }
        }
    }
}
