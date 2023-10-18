//
//  CoreNetworking.swift
//  KeymeKit
//
//  Created by 이영빈 on 2023/07/18.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Combine
import Foundation

import Moya

protocol CoreNetworking<APIType> {
    associatedtype APIType: TargetType
    
    /// Swift concurrency 맥락에서 네트워크 요청
    func request(_ api: APIType) async throws -> Response
    
    /// Combine 맥락에서 네트워크 요청
    func request(_ api: APIType) -> AnyPublisher<Response, MoyaError>
    
    /// 인증토큰 헤더에 넣어주는 메서드
    func registerAuthorizationToken(_ authorizationToken: String?)
    
    var authorizationToken: String? { get }
}
