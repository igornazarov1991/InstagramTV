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
import Swiftagram

struct LoginState: Equatable {
    var username: String = "johanakropol2"
    var password: String = "johanakropol"
    var twoFactorChallenge: TwoFactor?

    init() {}
}

enum LoginAction: Equatable {
    case fetchSecret
    case fetchSecretResponse(Result<Secret, AuthenticationClient.Error>)
    case loginButtonTapped
    case loginResponse(Result<Secret, AuthenticationClient.Error>)
    case sendTwoFactor(code: String)
    case twoFactorResponse(Result<Secret, AuthenticationClient.Error>)
}

struct LoginEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var authenticationClient: AuthenticationClient

    static let live = Self(
        mainQueue: .main,
        authenticationClient: .live
    )
}

let loginReducer = Reducer<
    LoginState,
    LoginAction,
    LoginEnvironment
> { state, action, environment in
    switch action {
    case .fetchSecret:
        return environment.authenticationClient.fetchSecret()
            .receive(on: environment.mainQueue)
            .catchToEffect(LoginAction.fetchSecretResponse)

    case .fetchSecretResponse(.success(let secret)):
        return .none

    case .fetchSecretResponse(.failure(let error)):
        return .none

    case .loginButtonTapped:
        return environment.authenticationClient.authenticate(
            state.username,
            state.password
        )
            .receive(on: environment.mainQueue)
            .catchToEffect(LoginAction.loginResponse)

    case .loginResponse(.success(let secret)):
        return .none

    case .loginResponse(.failure(.twoFactorChallenge(let challenge))):
        state.twoFactorChallenge = challenge
        return .none

    case .loginResponse(.failure(let error)):
        return .none

    case .sendTwoFactor(code: let code):
        return environment.authenticationClient.sendTwoFactor(state.twoFactorChallenge, code)
            .receive(on: environment.mainQueue)
            .catchToEffect(LoginAction.twoFactorResponse)

    case .twoFactorResponse(.success(let result)):
        print(result)
        return .none

    case .twoFactorResponse(.failure(let error)):
        print(error)
        return .none
    }
}

struct AuthenticationClient {
    var authenticate: (String, String) -> Effect<Secret, Error>
    var fetchSecret: () -> Effect<Secret, Error>
    var sendTwoFactor: (TwoFactor?, String) -> Effect<Secret, Error>

    static private var bin: Set<AnyCancellable> = []

    enum Error: Swift.Error, Equatable {
        case generic
        case emptyToken
        case twoFactorChallenge(TwoFactor)
        case twoFactorFailed
    }
}

extension AuthenticationClient {
    static let live = Self(
        authenticate: { username, password in
            Effect<Secret, Error>.future { callback in
                Authenticator.keychain
                    .basic(
                        username: username,
                        password: password
                    )
                    .authenticate()
                    .sink(
                        receiveCompletion: {
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
                                    callback(.failure(.twoFactorChallenge(challenge)))
                                default:
                                    callback(.failure(.generic))
                                }
                            default:
                                break
                            }
                        },
                        receiveValue: { secret in
                            callback(.success(secret))
                        }
                    )
                    .store(in: &bin)
            }
        },

        fetchSecret: {
            Effect<Secret, Error>.future { callback in
                if let secret = try? Authenticator.keychain.secrets.get().first {
                    callback(.success(secret))
                } else {
                    callback(.failure(.emptyToken))
                }
            }
        },

        sendTwoFactor: { challenge, code in
            Effect<Secret, Error>.future { callback in
                challenge?
                    .code(code)
                    .authenticate()
                    .sink(
                        receiveCompletion: { _ in
                            callback(.failure(.twoFactorFailed))
                        },
                        receiveValue: { secret in
                            callback(.success(secret))
                        }
                    )
                    .store(in: &bin)
            }
        }
    )
}
