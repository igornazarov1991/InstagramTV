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
