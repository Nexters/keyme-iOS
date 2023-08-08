//
//  TestAPIManger.swift
//  Keyme
//
//  Created by Young Bin on 2023/07/16.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

import Combine
import CombineMoya
import Moya

public struct TestAPIManager {
    public typealias APIType = TestAPI

    private var core: CoreNetworkService<TestAPI>
    private let decoder = JSONDecoder()

    init(core: CoreNetworkService<TestAPI>) {
        self.core = core
    }

    @discardableResult
    public mutating func registerAuthorizationToken(_ token: String) -> Self {
        core.registerAuthorizationToken(token)
        return self
    }
}

extension TestAPIManager: CoreNetworking {
    public func request(_ api: TestAPI) async throws -> Response {
        try await core.request(api)
    }

    public func request(_ api: TestAPI) -> AnyPublisher<Response, MoyaError> {
        core.request(api)
    }
}

extension TestAPIManager: APIRequestable {
    public func request<T: Decodable>(_ api: TestAPI, object: T.Type) async throws -> T {
        let response = try await core.request(api)
        let decoded = try decoder.decode(T.self, from: response.data)

        return decoded
    }

    public func request<T: Decodable>(_ api: TestAPI, object: T.Type) -> AnyPublisher<T, MoyaError> {
        core.request(api).map(T.self)
    }
}

public extension TestAPIManager {
    static let shared = TestAPIManager(core: .init())
}
