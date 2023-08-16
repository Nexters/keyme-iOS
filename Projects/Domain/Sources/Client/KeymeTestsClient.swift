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
            var response = try await KeymeTestsAPIManager.shared.request(api, object: KeymeTestsDTO.self)

            return response.toIconModel()
        }
    )
}
