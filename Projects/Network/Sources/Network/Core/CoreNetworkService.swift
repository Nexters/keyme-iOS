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

public class CoreNetworkService<APIType: TargetType> {
    private var token: String?
    public private(set) var provider: MoyaProvider<APIType>
    
    init(provider: MoyaProvider<APIType>) {
        self.provider = provider
    }
}

extension CoreNetworkService: CoreNetworking {
    var authorizationToken: String? {
        self.token
    }
    
    func request(_ api: APIType) async throws -> Response {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(api) { result in
                switch result {
                case let .success(response) where 200..<300 ~= response.statusCode:
                    continuation.resume(returning: response)
                case let .success(response) where 300... ~= response.statusCode:
                    continuation.resume(throwing: MoyaError.statusCode(response))
                case let .failure(error):
                    continuation.resume(throwing: error)
                default:
                    let unexpectedError = NSError(domain: "Unexpected Response", code: 0, userInfo: nil)
                    continuation.resume(throwing: unexpectedError)
                }
            }
        }
    }
    
    func request(_ api: APIType) -> AnyPublisher<Response, MoyaError> {
        provider.requestPublisher(api)
    }
    
    func registerAuthorizationToken(_ authorizationToken: String?) {
        let loggerConfig = NetworkLoggerPlugin.Configuration(logOptions: .verbose)
        let networkLogger = NetworkLoggerPlugin(configuration: loggerConfig)
        
        let newProvider = MoyaProvider<APIType>(
            endpointClosure: endpointClosure(with: authorizationToken ?? ""),
            plugins: [networkLogger])
        
        provider = newProvider
        token = authorizationToken
    }
}

private extension CoreNetworkService {
    func endpointClosure(with token: String) -> MoyaProvider<APIType>.EndpointClosure {
        return { (target: APIType) -> Endpoint in
            var endpoint = MoyaProvider.defaultEndpointMapping(for: target)
            endpoint = endpoint.adding(newHTTPHeaderFields: ["Authorization": "Bearer \(token)"])
            
            return endpoint
        }
    }
}
