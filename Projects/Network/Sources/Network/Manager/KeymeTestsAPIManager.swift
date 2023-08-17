//
//  KeymeTestsAPIManager.swift
//  Network
//
//  Created by 김영인 on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

import Combine
import CombineMoya
import Moya

public class KeymeTestsAPIManager {
    public typealias APIType = KeymeTestsAPI

    private var core: CoreNetworkService<KeymeTestsAPI>
    private let decoder = JSONDecoder()

    init(core: CoreNetworkService<KeymeTestsAPI>) {
        self.core = core
    }

    public func registerAuthorizationToken(_ token: String) {
        core.registerAuthorizationToken(token)
    }
}

extension KeymeTestsAPIManager: APIRequestable {
    public func request<T: Decodable>(_ api: KeymeTestsAPI, object: T.Type) async throws -> T {
        let response = try await core.request(api)
        let decoded = try decoder.decode(T.self, from: response.data)

        return decoded
    }
    
    public func requestWithSampleData<T: Decodable>(_ api: KeymeTestsAPI, object: T.Type) async throws -> T {
        let response = api.sampleData
        let decoded = try decoder.decode(T.self, from: response)

        return decoded
    }

    public func request<T: Decodable>(_ api: KeymeTestsAPI, object: T.Type) -> AnyPublisher<T, MoyaError> {
        core.request(api).map(T.self)
    }
}

public extension KeymeTestsAPIManager {
    static let shared = KeymeTestsAPIManager(core: .init(provider: .init()))
}
