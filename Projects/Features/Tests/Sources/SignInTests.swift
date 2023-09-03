import XCTest
import ComposableArchitecture

import Network
@testable import Features

class SignInFeatureTests: XCTestCase {
    private var testStore: TestStoreOf<SignInFeature>!
    
    override func setUpWithError() throws {
        testStore = TestStore(initialState: SignInFeature.State.notDetermined, reducer: {
            SignInFeature()
        }, withDependencies: { dependency in
            dependency.userStorage = .testValue
        })
    }
}
