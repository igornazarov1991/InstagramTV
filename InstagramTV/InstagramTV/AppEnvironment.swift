//
//  AppEnvironment.swift
//  InstagramTV
//
//  Created by Igor Nazarov on 09.12.2021.
//

import Foundation
import CombineSchedulers
import ComposableArchitecture

struct AppEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var authenticator: AuthenticationClient

    static let live = Self(
        mainQueue: .main,
        authenticator: .live
    )
}

struct AuthenticationClient {
    var authenticate: (String, String) -> Effect<String, Error>

    struct Error: Swift.Error, Equatable {}
}

extension AuthenticationClient {
    static let live = Self(
        authenticate: { username, password in
            return Effect(value: "\(username)+\(password)")
        }
    )
}
