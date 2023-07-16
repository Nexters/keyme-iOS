//
//  NetworkManagerTests.swift
//  KeymeTests
//
//  Created by Young Bin on 2023/07/16.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import XCTest

import Moya

@testable import KeymeKit

final class NetworkManagerTests: XCTestCase {
    var networkManager: NetworkManager!

    override func setUpWithError() throws {
        let stubbedProvider = MoyaProvider<KeymeAPI>(stubClosure: MoyaProvider.immediatelyStub)
        networkManager = NetworkManager(provider: stubbedProvider)
    }

    override func tearDownWithError() throws {
        networkManager = nil
    }
    
    func testRequestSuccess() async {
        let testTarget: KeymeAPI = .test
        let expectedResponseData = testTarget.sampleData
        
        do {
            let response = try await networkManager.request(testTarget)
            let responseData = response.data
            XCTAssertEqual(responseData, expectedResponseData, "Response data does not match expected data.")
        } catch {
            XCTFail("Request failed with error: \(error)")
        }
    }
    
    func testRequestFailure() async {
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
        networkManager = NetworkManager(provider: stubbedProvider)
        
        let testTarget: KeymeAPI = .test
        do {
            _ = try await networkManager.request(testTarget)
            XCTFail("Request should have failed but it succeeded.")
        } catch {
            return
        }
    }
    
    func testCombineRequestSuccess() {
        let testTarget: KeymeAPI = .test
        let expectedResponseData = testTarget.sampleData

        let expectation = XCTestExpectation(description: "Receive response")
        let cancellable = networkManager.request(testTarget)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    XCTFail("Request failed with error: \(error)")
                }
                expectation.fulfill()
            } receiveValue: { response in
                let responseData = response.data
                XCTAssertEqual(responseData, expectedResponseData, "Response data does not match expected data.")
            }

        wait(for: [expectation], timeout: 1)
        cancellable.cancel()
    }
    
    func testCombineRequestFailure() {
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
        networkManager = NetworkManager(provider: stubbedProvider)

        let testTarget: KeymeAPI = .test

        let expectation = XCTestExpectation(description: "Receive response")
        let cancellable = networkManager.request(testTarget)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTFail("Request should have failed but it succeeded.")
                case .failure(let error):
                    break
                }
                expectation.fulfill()
            } receiveValue: { _ in
                XCTFail("Request should have failed but it received a value.")
            }

        wait(for: [expectation], timeout: 1.0)
        cancellable.cancel()
    }

    func testRegisterAuthorizationToken() {
        let testTarget: KeymeAPI = .test
        let token = "test_token"
        
        var endpoint = networkManager.provider.endpointClosure(testTarget)
        XCTAssertNil(
            endpoint.httpHeaderFields?["Authorization"],
            "Authorization token should not exist.")
        
        networkManager.registerAuthorizationToken(token)

        endpoint = networkManager.provider.endpointClosure(testTarget)
        XCTAssertEqual(
            endpoint.httpHeaderFields?["Authorization"],
            token,
            "Authorization token does not match expected token.")
    }
}
