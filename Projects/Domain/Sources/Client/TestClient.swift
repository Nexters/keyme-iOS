//
//  TestClient.swift
//  Domain
//
//  Created by 김영인 on 2023/07/29.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture

import Network

public struct TestClient {
    public var fetchTest: @Sendable () async throws -> TestModel
}

extension DependencyValues {
    public var testClient: TestClient {
        get { self[TestClient.self] }
        set { self[TestClient.self] = newValue }
    }
}

extension TestClient: DependencyKey {
    public static var liveValue = TestClient(
        fetchTest: {
//            let api = TestAPI.hello
//            let response = try await TestAPIManager.shared.request(api)
//            let decoded = String(data: response.data, encoding: .utf8)!
//
//            return TestDTO(hello: decoded).toModel()
            return .init(hello: "")
        }
    )
}
