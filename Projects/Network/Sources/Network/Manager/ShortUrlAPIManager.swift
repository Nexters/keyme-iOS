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
}

public extension ShortUrlAPIManager {
    static let shared = ShortUrlAPIManager()
}
