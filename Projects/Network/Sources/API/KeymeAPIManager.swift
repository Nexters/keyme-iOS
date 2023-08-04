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

public struct KeymeAPIManager {
    public typealias APIType = KeymeAPI
    
    private var core: CoreNetworkService<KeymeAPI>
    private let decoder = JSONDecoder()
    
    init(core: CoreNetworkService<KeymeAPI>) {
        self.core = core
    }
    
    @discardableResult
    public mutating func registerAuthorizationToken(_ token: String) -> Self {
        core.registerAuthorizationToken(token)
        return self
    }
}

extension KeymeAPIManager: CoreNetworking {
    public func request(_ api: KeymeAPI) async throws -> Response {
        try await core.request(api)
    }
    
    public func request(_ api: KeymeAPI) -> AnyPublisher<Response, MoyaError> {
        core.request(api)
    }
}

extension KeymeAPIManager: APIRequestable {
    public func request<T: Decodable>(_ api: KeymeAPI, object: T.Type) async throws -> T {
        let response = try await core.request(api)
        let decoded = try decoder.decode(T.self, from: response.data)
        
        return decoded
    }
    
    public func request<T: Decodable>(_ api: KeymeAPI, object: T.Type) -> AnyPublisher<T, MoyaError> {
        core.request(api).map(T.self)
    }
}

public extension KeymeAPIManager {
    static let shared = KeymeAPIManager(core: .init())
}
