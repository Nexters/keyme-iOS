//
//  NetworkManager.swift
//  Keyme
//
//  Created by Young Bin on 2023/07/16.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

import Combine
import CombineMoya
import Moya

public struct KeymeAPIManager<APIType: TargetType> {
    public typealias APIType = APIType
    
    private var core: CoreNetworkService<APIType>
    private let decoder = JSONDecoder()
    
    init(core: CoreNetworkService<APIType>) {
        self.core = core
    }
    
    @discardableResult
    public mutating func registerAuthorizationToken(_ token: String) -> Self {
        core.registerAuthorizationToken(token)
        return self
    }
}

extension KeymeAPIManager: CoreNetworking {
    public func request(_ api: APIType) async throws -> Response {
        try await core.request(api)
    }
    
    public func request(_ api: APIType) -> AnyPublisher<Response, MoyaError> {
        core.request(api)
    }
}

extension KeymeAPIManager: APIRequestable {
    public func request<T: Decodable>(_ api: APIType, object: T.Type) async throws -> T {
        let response = try await core.request(api)
        let decoded = try decoder.decode(T.self, from: response.data)
        
        return decoded
    }
    
    public func request<T: Decodable>(_ api: APIType, object: T.Type) -> AnyPublisher<T, MoyaError> {
        core.request(api).map(T.self)
    }
}

public extension KeymeAPIManager {
    static var shared: KeymeAPIManager<APIType> {
        return KeymeAPIManager<APIType>(core: .init())
    }
}
