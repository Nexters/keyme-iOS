//
//  CoreNetworkServiceTests.swift
//  KeymeTests
//
//  Created by 이영빈 on 2023/07/18.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

@testable import Network

import Moya
import XCTest

final class CoreNetworkServiceTests: XCTestCase {
    private var coreNetworkService: CoreNetworkService<TestAPI>!

    override func setUpWithError() throws {
        let stubbedProvider = MoyaProvider<TestAPI>(stubClosure: MoyaProvider.immediatelyStub)
        coreNetworkService = CoreNetworkService(provider: stubbedProvider)
    }

    override func tearDownWithError() throws {
        coreNetworkService = nil
    }
}

// MARK: 요청 성공 케이스
extension CoreNetworkServiceTests {
    func testRequest_success() async {
        let testTarget: TestAPI = .test
        let expectedResponseData = testTarget.sampleData
        
        do {
            let response = try await coreNetworkService.request(testTarget)
            let responseData = response.data
            XCTAssertEqual(responseData, expectedResponseData, "Response data does not match expected data.")
        } catch {
            XCTFail("Request failed with error: \(error)")
        }
    }
    
    func testCombineRequest_success() {
        let testTarget: TestAPI = .test
        let expectedResponseData = testTarget.sampleData

        let expectation = XCTestExpectation(description: "Receive response")
        let cancellable = coreNetworkService.request(testTarget)
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
}

// MARK: 실패 케이스
extension CoreNetworkServiceTests {
    func testRequest_failure() async {
        setupErrorStub()
        
        let testTarget: TestAPI = .test
        do {
            _ = try await coreNetworkService.request(testTarget)
            XCTFail("Request should have failed but it succeeded.")
        } catch {
            return
        }
    }
    
    func testCombineRequest_failure() {
        setupErrorStub()

        let testTarget: TestAPI = .test
        let expectation = XCTestExpectation(description: "Receive response")
        let cancellable = coreNetworkService.request(testTarget)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTFail("Request should have failed but it succeeded.")
                case .failure:
                    break
                }
                expectation.fulfill()
            } receiveValue: { _ in
                XCTFail("Request should have failed but it received a value.")
            }

        wait(for: [expectation], timeout: 1.0)
        cancellable.cancel()
    }
    
    private func setupErrorStub() {
        let stubbedError = MoyaError.stringMapping(Response(statusCode: 400, data: Data()))
        
        let endpointClosure = { (target: TestAPI) -> Endpoint in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: { .networkError(stubbedError as NSError) },
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }
        
        let stubbedProvider = MoyaProvider<TestAPI>(
            endpointClosure: endpointClosure,
            stubClosure: MoyaProvider.immediatelyStub)
        coreNetworkService = CoreNetworkService(provider: stubbedProvider)
    }
}

// MARK: 그 외
extension CoreNetworkServiceTests {
    func testRegisterAuthorizationToken() {
        let testTarget: TestAPI = .test
        let token = "test_token"
        
        var endpoint = coreNetworkService.provider.endpointClosure(testTarget)
        XCTAssertNil(
            endpoint.httpHeaderFields?["Authorization"],
            "Authorization token should not exist.")
        
        coreNetworkService.registerAuthorizationToken(token)

        endpoint = coreNetworkService.provider.endpointClosure(testTarget)
        XCTAssertEqual(
            endpoint.httpHeaderFields?["Authorization"],
            token,
            "Authorization token does not match expected token.")
    }
}

// MARK: Data for tests
extension CoreNetworkServiceTests {
    enum TestAPI: TargetType {
        case test
        
        var baseURL: URL {
            URL(string: "www.naver.com")!
        }
        
        var path: String {
            "path"
        }
        
        var method: Moya.Method {
            .get
        }
        
        var task: Moya.Task {
            .requestPlain
        }
        
        var headers: [String : String]? {
            [:]
        }
        
        var sampleData: Data {
                """
                {
                    "id": 1,
                    "name": "Test Item"
                }
                """.data(using: .utf8)!
        }
    }
    
    struct TestItem: Decodable {
        let id: Int
        let name: String
    }
}
