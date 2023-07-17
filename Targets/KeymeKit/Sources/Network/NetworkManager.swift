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

protocol MoyaNetworking {
    associatedtype APIType: TargetType
    
    /// Swift concurrency 맥락에서 네트워크 요청
    func request(_ api: APIType) async throws -> Response
    
    /// Combine 맥락에서 네트워크 요청
    func request(_ api: APIType) -> AnyPublisher<Response, MoyaError>
    
    /// 인증토큰 헤더에 넣어주는 메서드
    mutating func registerAuthorizationToken(_ token: String)
}

public struct NetworkManager {
    public static let shared = NetworkManager()
    
    private(set) var provider: MoyaProvider<KeymeAPI>
    
    init(provider: MoyaProvider<KeymeAPI> = .init()) {
        self.provider = provider
    }
}

extension NetworkManager: MoyaNetworking {
    public func request(_ api: KeymeAPI) async throws -> Response {
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
    
    public func request(_ api: KeymeAPI) -> AnyPublisher<Response, MoyaError> {
        provider.requestPublisher(api)
    }
    
    public mutating func registerAuthorizationToken(_ authorizationToken: String) {
        self.provider = MoyaProvider<KeymeAPI>(endpointClosure: endpointClosure(with: authorizationToken))
    }
}

private extension NetworkManager {
    func endpointClosure(with token: String) -> MoyaProvider<KeymeAPI>.EndpointClosure {
        return { (target: KeymeAPI) -> Endpoint in
            let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)

            switch target {
            case .test:
                return defaultEndpoint.adding(newHTTPHeaderFields: ["Authorization": token])
            }
        }
    }
}
