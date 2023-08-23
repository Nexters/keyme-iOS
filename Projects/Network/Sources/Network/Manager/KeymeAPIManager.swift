//
//  KeymeAPIManager.swift
//  Network
//
//  Created by 김영인 on 2023/08/07.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Combine
import CombineMoya
import Moya
import Foundation

public class KeymeAPIManager {
    public typealias APIType = KeymeAPI

    private var core: CoreNetworkService<KeymeAPI>
    private let decoder = JSONDecoder()
    
    init() {
        let loggerConfig = NetworkLoggerPlugin.Configuration(logOptions: .verbose)
        let networkLogger = NetworkLoggerPlugin(configuration: loggerConfig)
        let provider = MoyaProvider<KeymeAPI>(plugins: [networkLogger])
        
        self.core = CoreNetworkService(provider: provider)
    }
    
    init(core: CoreNetworkService<KeymeAPI>) {
        self.core = core
    }

    public func registerAuthorizationToken(_ token: String) {
        core.registerAuthorizationToken(token)
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
    static let shared = KeymeAPIManager()
}

import ComposableArchitecture

extension KeymeAPIManager: DependencyKey {
    public static var liveValue = KeymeAPIManager()
    public static var testValue: KeymeAPIManager {
        let stubbingClosure = MoyaProvider<KeymeAPI>.immediatelyStub
        let stubbingCoreService = CoreNetworkService<KeymeAPI>(provider: .init(stubClosure: stubbingClosure))
        return KeymeAPIManager(core: stubbingCoreService)
    }
}

extension DependencyValues {
    public var keymeAPIManager: KeymeAPIManager {
        get { self[KeymeAPIManager.self] }
        set { self[KeymeAPIManager.self] = newValue }
    }
}
