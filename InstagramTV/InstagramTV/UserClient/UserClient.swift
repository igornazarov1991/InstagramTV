//
//  UserClient.swift
//  InstagramTV
//
//  Created by Igor Nazarov on 01.01.2022.
//

import Foundation
import ComposableArchitecture
import Swiftagram

struct UserClient {
    var fetchCurrentUser: (Secret) -> Effect<User?, Error>

    static private var bin: Set<AnyCancellable> = []

    enum Error: Swift.Error, Equatable {
        case generic
    }
}

extension UserClient {
    static let live = Self(
        fetchCurrentUser: { secret in
            Effect<User?, Error>.future { callback in
                Endpoint.user(secret.identifier)
                    .unlock(with: secret)
                    .session(.instagram)
                    .map(\.user)
                    .sink(
                        receiveCompletion: {
                            switch $0 {
                            case .failure(let error):
                                callback(.failure(.generic))
                            default:
                                break
                            }
                        },
                        receiveValue: { user in
                            callback(.success(user))
                        }
                    )
                    .store(in: &bin)
            }
        }
    )
}

#if DEBUG
extension UserClient {
    static let test = Self(
        fetchCurrentUser: { _ in .none }
    )
}
#endif
