//
//  APIRequestableTests.swift
//  KeymeKit
//
//  Created by 이영빈 on 2023/07/18.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

@testable import Network

import Moya
import XCTest

// 조금 더 정확히 표현하면 APIRequestable에 대한 테스트
final class KeymeAPIManagerTests: XCTestCase {
    private var mockCoreNetworkService: CoreNetworkService<KeymeAPI>!
    private var keymeAPIManager: KeymeAPIManager!
    
    override func setUpWithError() throws {
        let provider = MoyaProvider<KeymeAPI>(stubClosure: MoyaProvider.immediatelyStub)
        mockCoreNetworkService = CoreNetworkService<KeymeAPI>(provider: provider)
        keymeAPIManager = KeymeAPIManager(core: mockCoreNetworkService)
    }
    
    override func tearDownWithError() throws {
        mockCoreNetworkService = nil
        keymeAPIManager = nil
    }
}

// MARK: 성공 케이스
extension KeymeAPIManagerTests {
    func testRequest_returnsCorrectItem() async throws {
        let api = KeymeAPI.test
        let item = try await keymeAPIManager.request(api, object: TestItem.self)
        
        XCTAssertEqual(item.id, 1)
        XCTAssertEqual(item.name, "Test Item")
    }
    
    func testRequestWithPublisher_returnsCorrectItem() throws {
        let expectation = expectation(description: "Publisher completes and returns an item.")
        
        let api = KeymeAPI.test
        _ = keymeAPIManager.request(api, object: TestItem.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("Publisher failed with error: \(error)")
                }
            }, receiveValue: { item in
                XCTAssertEqual(item.id, 1)
                XCTAssertEqual(item.name, "Test Item")
            })
        
        waitForExpectations(timeout: 1)
    }
}

// MARK: 실패 케이스
extension KeymeAPIManagerTests {
    func testRequest_Fails() async throws {
        setUpErrorStub()
        
        do {
            // Use an endpoint that will cause a failure
            _ = try await keymeAPIManager.request(.test, object: TestItem.self)
            XCTFail("Request should have failed but didn't")
        } catch {
            return
        }
    }
    
    func testRequestWithPublisher_Fails() throws {
        setUpErrorStub()
        
        let expectation = XCTestExpectation()
        _ = keymeAPIManager.request(.test, object: TestItem.self)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure:
                        expectation.fulfill()
                    case .finished:
                        XCTFail("Publisher should have failed but completed normally")
                    }
                },
                receiveValue: { _ in XCTFail("Publisher should not have produced a value") }
            )
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    private func setUpErrorStub() {
        let stubbedError = MoyaError.stringMapping(Response(statusCode: 400, data: Data()))
        
        let endpointClosure = { (target: KeymeAPI) -> Endpoint in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: { .networkError(stubbedError as NSError) },
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }
        
        let stubbedProvider = MoyaProvider<KeymeAPI>(
            endpointClosure: endpointClosure,
            stubClosure: MoyaProvider.immediatelyStub)
        mockCoreNetworkService = CoreNetworkService(provider: stubbedProvider)
        keymeAPIManager = KeymeAPIManager(core: mockCoreNetworkService)
    }
}
