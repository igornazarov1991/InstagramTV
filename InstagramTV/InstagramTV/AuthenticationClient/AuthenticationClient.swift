//
//  AuthenticationClient.swift
//  InstagramTV
//
//  Created by Igor Nazarov on 01.01.2022.
//

import Foundation
import ComposableArchitecture
import Swiftagram

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
