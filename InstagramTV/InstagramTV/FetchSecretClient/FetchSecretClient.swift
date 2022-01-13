//
//  FetchSecretClient.swift
//  InstagramTV
//
//  Created by Igor Nazarov on 13.01.2022.
//

import Foundation
import ComposableArchitecture
import Swiftagram

struct FetchSecretClient {
    var fetchSecret: () -> Effect<Secret, Error>

    static private var bin: Set<AnyCancellable> = []

    enum Error: Swift.Error, Equatable {
        case emptyToken
    }
}

extension FetchSecretClient {
    static let live = Self(
        fetchSecret: {
            Effect<Secret, Error>.future { callback in
                if let secret = try? Authenticator.keychain.secrets.get().first {
                    callback(.success(secret))
                } else {
                    callback(.failure(.emptyToken))
                }
            }
        }
    )
}

#if DEBUG
extension FetchSecretClient {
    static let test = Self(
        fetchSecret: { .none }
    )

    static let emptySecret = Self(
        fetchSecret: { Effect<Secret, Error>(error: .emptyToken) }
    )
}
#endif
