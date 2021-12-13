//
//  Authentication.swift
//  InstagramTV
//
//  Created by Igor Nazarov on 13.12.2021.
//

import Foundation
import CombineSchedulers
import ComposableArchitecture
import SwiftagramCrypto

struct AuthenticationState: Equatable {
    var username = ""
    var password = ""
    var secret = ""

    static let initial = Self(
        username: "igor.nazarov.1991",
        password: "password",
        secret: ""
    )
}

enum AuthenticationAction: Equatable {
    case loginButtonTapped
    case authenticationResponse(Result<String, AuthenticationClient.Error>)
}

struct AuthenticationEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var authenticator: AuthenticationClient
}

let authenticationReducer = Reducer<AuthenticationState, AuthenticationAction, AuthenticationEnvironment> { state, action, environment in

    switch action {
    case .loginButtonTapped:
        return environment.authenticator.authenticate(
            state.username,
            state.password
        )
            .receive(on: environment.mainQueue)
            .catchToEffect(AuthenticationAction.authenticationResponse)

    case .authenticationResponse(.success(let secret)):
        state.secret = secret
        return .none

    case .authenticationResponse(.failure(let error)):
        return .none
    }
}

struct AuthenticationClient {
    var authenticate: (String, String) -> Effect<String, Error>
    private var bin: Set<AnyCancellable> = []

    struct Error: Swift.Error, Equatable {}
}

extension AuthenticationClient {
    static let live = Self(
        authenticate: { username, password in
            return Effect(value: "\(username)+\(password)")
        }
    )
}
