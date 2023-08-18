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
    public static var liveValue = KeymeTestsClient(
        fetchOnboardingTests: {
            let api = KeymeTestsAPI.onboarding
            //            var response = try await KeymeTestsAPIManager.shared.requestWithSampleData(api, object: KeymeTestsDTO.self)
            var response = try await KeymeTestsAPIManager.shared.request(api, object: KeymeTestsDTO.self)
            
            return response.toIconModel()
        }, fetchDailyTests: {
            let api = KeymeTestsAPI.daily
            //            var response = try await KeymeTestsAPIManager.shared.requestWithSampleData(api, object: KeymeTestsDTO.self)
            var response = try await KeymeTestsAPIManager.shared.request(api, object: KeymeTestsDTO.self)
            
            return response.toIconModel()
        }, fetchTestResult: { testResultId in
            let api = KeymeTestsAPI.result(testResultId)
            //            var response = try await KeymeTestsAPIManager.shared.requestWithSampleData(api, object: TestResultDTO.self)
            var response = try await KeymeTestsAPIManager.shared.request(api, object: TestResultDTO.self)
            
            return response.data.results.map { $0.toModel() }
        }, postTestResult: { resultCode in
            let api = KeymeTestsAPI.register(resultCode)
            //            var response = try await KeymeTestsAPIManager.shared.requestWithSampleData(api, object: BaseDTO<String>.self)
            var response = try await KeymeTestsAPIManager.shared.request(api, object: BaseDTO<String>.self)
            
            return response.message
        }
    )
}
