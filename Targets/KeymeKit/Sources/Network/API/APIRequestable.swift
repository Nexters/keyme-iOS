//
//  APIRequestable.swift
//  KeymeKit
//
//  Created by 이영빈 on 2023/07/18.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Combine
import CombineMoya
import Moya
import Foundation

protocol APIRequestable<APIType> {
    associatedtype APIType: TargetType
    
    var core: CoreNetworkService<APIType> { get set }
    var decoder: JSONDecoder { get }
    
    /// Swift concurrency 맥락에서 네트워크 요청
    func request<T: Decodable>(_ api: APIType, object: T.Type) async throws -> T
    
    /// Combine 맥락에서 네트워크 요청
    func request<T: Decodable>(_ api: APIType, object: T.Type) -> AnyPublisher<T, MoyaError>
    
    /// 인증토큰 헤더에 넣어주는 메서드
    mutating func registerAuthorizationToken(_ token: String) -> Self
}

extension APIRequestable {
    func request<T: Decodable>(_ api: APIType, object: T.Type) async throws -> T {
        let response = try await core.request(api)
        let decoded = try decoder.decode(T.self, from: response.data)
        
        return decoded
    }
    
    func request<T: Decodable>(_ api: APIType, object: T.Type) -> AnyPublisher<T, MoyaError> {
        core.request(api).map(T.self)
    }
    
    mutating func registerAuthorizationToken(_ token: String) -> Self {
        core.registerAuthorizationToken(token)
        return self
    }
}
