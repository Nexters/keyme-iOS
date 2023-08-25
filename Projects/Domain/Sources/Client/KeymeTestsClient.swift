//
//  KeymeTestsClient.swift
//  Domain
//
//  Created by 김영인 on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture

import Network

public struct KeymeTestsClient {
    public var fetchOnboardingTests: @Sendable () async throws -> KeymeTestsModel
    public var fetchDailyTests: @Sendable () async throws -> KeymeTestsModel
    public var fetchTestResult: @Sendable (Int) async throws -> [TestResultModel]
    public var postTestResult: @Sendable (String) async throws -> String
}

extension DependencyValues {
    public var keymeTestsClient: KeymeTestsClient {
        get { self[KeymeTestsClient.self] }
        set { self[KeymeTestsClient.self] = newValue }
    }
}

extension KeymeTestsClient: DependencyKey {
    public static var liveValue = getClient(with: KeymeAPIManager.liveValue)
    public static var testValue = getClient(with: KeymeAPIManager.testValue)
}

private func getClient(with network: KeymeAPIManager) -> KeymeTestsClient {
     KeymeTestsClient(
        fetchOnboardingTests: {
            let api = KeymeAPI.test(.onboarding)
            let response = try await network.request(api, object: KeymeTestsDTO.self)
            
            return response.toIconModel()
        }, fetchDailyTests: {
            let api = KeymeAPI.test(.daily)
            let response = try await network.request(api, object: KeymeTestsDTO.self)
            
            return response.toIconModel()
        }, fetchTestResult: { testResultId in
            let api = KeymeAPI.test(.result(testResultId))
            let response = try await network.request(api, object: TestResultDTO.self)
            
            return response.data.results.map { $0.toModel() }
        }, postTestResult: { resultCode in
            let api = KeymeAPI.test(.register(resultCode))
            let response = try await network.request(api, object: BaseDTO<String>.self)
            
            return response.message
        }
    )
}
