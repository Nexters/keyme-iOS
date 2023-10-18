//
//  APIRequestable.swift
//  KeymeKit
//
//  Created by 이영빈 on 2023/07/18.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Combine
import Foundation

import Moya

public protocol APIRequestable<APIType> {
    associatedtype APIType: TargetType
    
    /// Swift concurrency 맥락에서 네트워크 요청. 그런데 디코딩을 곁들인
    ///
    /// - Parameters:
    ///     - object: `받아_볼_타입.self`
    func request<T: Decodable>(_ api: APIType, object: T.Type) async throws -> T
    
    /// Combine 맥락에서 네트워크 요청. 그런데 디코딩을 곁들인
    ///
    /// - Parameters:
    ///     - object: `받아_볼_타입.self`
    func request<T: Decodable>(_ api: APIType, object: T.Type) -> AnyPublisher<T, MoyaError>
    
    /// 인증토큰 헤더에 넣어주는 메서드
    func registerAuthorizationToken(_ token: String?)
    
    /// 인증토큰
    var authorizationToken: String? { get }
}
