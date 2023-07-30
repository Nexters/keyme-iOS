//
//  CoreNetworkService.swift
//  Keyme
//
//  Created by Young Bin on 2023/07/18.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Combine
import Foundation

import Moya

public struct CoreNetworkService<APIType: TargetType> {
    public private(set) var provider: MoyaProvider<APIType>
    
    init(provider: MoyaProvider<APIType> = .init()) {
        self.provider = provider
    }
}

extension CoreNetworkService: CoreNetworking {
    func request(_ api: APIType) async throws -> Response {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(api) { result in
                switch result {
                case let .success(response):
                    continuation.resume(returning: response)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func request(_ api: APIType) -> AnyPublisher<Response, MoyaError> {
        provider.requestPublisher(api)
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
