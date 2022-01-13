//
//  InstagramTVTests.swift
//  InstagramTVTests
//
//  Created by Igor Nazarov on 09.12.2021.
//

import XCTest
@testable import InstagramTV
import ComposableArchitecture
import Swiftagram

class InstagramTVTests: XCTestCase {

    let scheduler = DispatchQueue.test

    func testEmptySecret() {
        let store = TestStore(
            initialState: AppState(),
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                authenticationClient: .emptySecret,
                userClient: .test
            )
        )

        store.send(.login(.fetchSecret))

        scheduler.advance()
        store.receive(.login(.fetchSecretResponse(.failure(.emptyToken)))) {
            $0 = .login(LoginState())
        }
    }

}
