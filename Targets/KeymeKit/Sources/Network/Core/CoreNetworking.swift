//
//  CoreNetworking.swift
//  KeymeKit
//
//  Created by 이영빈 on 2023/07/18.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Combine
import CombineMoya
import Moya
import Foundation

protocol CoreNetworking<APIType> {
    associatedtype APIType: TargetType

    var provider: MoyaProvider<APIType> { get }
    
    /// Swift concurrency 맥락에서 네트워크 요청
    func request(_ api: APIType) async throws -> Response
    
    /// Combine 맥락에서 네트워크 요청
    func request(_ api: APIType) -> AnyPublisher<Response, MoyaError>
    
    /// 인증토큰 헤더에 넣어주는 메서드
    @discardableResult
    mutating func registerAuthorizationToken(_ authorizationToken: String) -> Self
}

extension CoreNetworking {
    func request(_ api: APIType) async throws -> Response {
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
    
    func request(_ api: APIType) -> AnyPublisher<Response, MoyaError> {
        provider.requestPublisher(api)
    }
}
