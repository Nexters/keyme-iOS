//
//  ShortUrlAPIManager.swift
//  Network
//
//  Created by Young Bin on 2023/08/18.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Moya
import Foundation

public class ShortUrlAPIManager {
    public typealias APIType = ShortUrlAPI

    private var core: CoreNetworkService<APIType>
    private let decoder = JSONDecoder()
    
    // 캐싱
    private var lastRequestedURLs: [String: String] = [:]

    init() {
        let loggerConfig = NetworkLoggerPlugin.Configuration(logOptions: .verbose)
        let networkLogger = NetworkLoggerPlugin(configuration: loggerConfig)
        let provider = MoyaProvider<APIType>(plugins: [networkLogger])
        
        self.core = CoreNetworkService(provider: provider)
    }
    
    init(core: CoreNetworkService<APIType>) {
        self.core = core
    }
}

extension ShortUrlAPIManager {
    public func request(_ api: APIType) async throws -> Response {
        try await core.request(api)
    }
}

extension ShortUrlAPIManager {
    public func request<T: Decodable>(_ api: APIType, object: T.Type) async throws -> T {
        let response = try await core.request(api)
        let decoded = try decoder.decode(T.self, from: response.data)

        return decoded
    }
    
    public func request(_ api: APIType, object: String) async throws -> String {
        if
            case .shortenURL(longURL: let url) = api,
            let lastResponsedURL = lastRequestedURLs[url]
        {
            return lastResponsedURL
        }
        
        let response = try await core.request(api)
        let decoded = try decoder.decode(String.self, from: response.data)
        
        if case .shortenURL(longURL: let url) = api {
            lastRequestedURLs[url] = decoded
        }
        
        return decoded
    }
}

// MARK: Dependency 설정
import ComposableArchitecture

extension ShortUrlAPIManager: DependencyKey {
    public static var liveValue = ShortUrlAPIManager()
    public static var testValue: ShortUrlAPIManager {
        let stubbingClosure = MoyaProvider<ShortUrlAPI>.immediatelyStub
        let stubbingCoreService = CoreNetworkService<ShortUrlAPI>(provider: .init(stubClosure: stubbingClosure))
        return ShortUrlAPIManager(core: stubbingCoreService)
    }
}

extension DependencyValues {
    public var shortUrlAPIManager: ShortUrlAPIManager {
        get { self[ShortUrlAPIManager.self] }
        set { self[ShortUrlAPIManager.self] = newValue }
    }
}
