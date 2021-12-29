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

struct AuthenticationState: Equatable {
    var username: String
    var password: String
    var isLoggedIn: Bool
    var isLoginPresented: Bool
    var secret: Secret?
    var twoFactorNeeded: Bool
    var twoFactorChallenge: TwoFactor?

    static let initial = Self(
        username: "johanakropol",
        password: "MiVidaLoca2020",
        isLoggedIn: false,
        isLoginPresented: false,
        twoFactorNeeded: false
    )
}

enum AuthenticationAction: Equatable {
    case setLoginSheet(presented: Bool)
    case fetchSecretToken
    case secretTokenResponse(Result<Secret, AuthenticationClient.Error>)
    case loginButtonTapped
    case authenticationResponse(Result<Secret, AuthenticationClient.Error>)
    case sendTwoFactor(code: String)
    case twoFactorResponse(Result<Secret, AuthenticationClient.Error>)
}

struct AuthenticationEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var authenticator: AuthenticationClient
}

let authenticationReducer = Reducer<
    AuthenticationState,
    AuthenticationAction,
    AuthenticationEnvironment
> { state, action, environment in

    switch action {
    case .setLoginSheet(presented: let presented):
        state.isLoginPresented = presented
        return .none

    case .fetchSecretToken:
        return environment.authenticator.fetchSecret()
            .receive(on: environment.mainQueue)
            .catchToEffect(AuthenticationAction.secretTokenResponse)

    case .secretTokenResponse(.success(let secret)):
        state.isLoggedIn = true
        state.isLoginPresented = false
        state.secret = secret
        return .none

    case .secretTokenResponse(.failure(let error)):
        state.isLoggedIn = false
        state.isLoginPresented = true
        return .none

    case .loginButtonTapped:
        return environment.authenticator.authenticate(
            state.username,
            state.password
        )
            .receive(on: environment.mainQueue)
            .catchToEffect(AuthenticationAction.authenticationResponse)

    case .authenticationResponse(.success(let secret)):
        state.isLoggedIn = true
        state.secret = secret
        return .none

    case .authenticationResponse(.failure(.twoFactorChallenge(let challenge))):
        state.isLoggedIn = false
        state.twoFactorNeeded = true
        state.twoFactorChallenge = challenge
        return .none

    case .authenticationResponse(.failure(let error)):
        state.isLoggedIn = false
        return .none

    case .sendTwoFactor(code: let code):
        return environment.authenticator.sendTwoFactor(state.twoFactorChallenge, code)
            .receive(on: environment.mainQueue)
            .catchToEffect(AuthenticationAction.twoFactorResponse)

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

    enum Error: Swift.Error, Equatable {
        case generic
        case emptyToken
        case twoFactorChallenge(TwoFactor)
    }
}

private var bin: Set<AnyCancellable> = []

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
                    })
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
                    .sink(receiveCompletion: {
                        print($0)
                    },
                          receiveValue: { result in
                        print(result)
                    })
                    .store(in: &bin)
            }
        }
    )
}
