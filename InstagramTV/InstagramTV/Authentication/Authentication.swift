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
    var username: String
    var password: String
    var isLoggedIn: Bool
    var loginInfo: String

    static let initial = Self(
        username: "igor.nazarov.1991",
        password: "password",
        isLoggedIn: false,
        loginInfo: ""
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

    case .authenticationResponse(.success(let result)):
        state.isLoggedIn = true
        state.loginInfo = result
        return .none

    case .authenticationResponse(.failure(let error)):
        state.isLoggedIn = false
        state.loginInfo = "\(error)"
        return .none
    }
}

struct AuthenticationClient {
    var authenticate: (String, String) -> Effect<String, Error>

    enum Error: Swift.Error, Equatable {
        case generic
    }
}

private var bin: Set<AnyCancellable> = []

extension AuthenticationClient {
    static let live = Self(
        authenticate: { username, password in
            Effect<String, Error>.future { callback in
                Authenticator.keychain
                    .basic(username: username,
                           password: password)
                    .authenticate()
                    .sink(receiveCompletion: {
                        switch $0 {
                        case .failure(let error):
                            // Deal with two factor authentication.
                            switch error {
                            case Authenticator.Error.twoFactorChallenge(let challenge):
                                // Once you receive the challenge,
                                // ask the user for the 2FA code
                                // then just call:
                                // `challenge.code(/* the code */).authenticate()`
                                // and deal with the publisher.
                                callback(.failure(.generic))
                            default:
                                callback(.failure(.generic))
                            }
                        default:
                            break
                        }
                    },
                          receiveValue: { secret in
                        callback(.success("Logged in as \(username)"))
                    })
                    .store(in: &bin)
            }
        }
    )
}
