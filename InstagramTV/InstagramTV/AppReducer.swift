//
//  AppReducer.swift
//  InstagramTV
//
//  Created by Igor Nazarov on 09.12.2021.
//

import Foundation
import ComposableArchitecture

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    .init { _, action, _ in
        switch action {
        default:
            return .none
        }
    },

    authenticationReducer
        .pullback(
            state: \.authentication,
            action: /AppAction.authentication,
            environment: { .init(
                mainQueue: $0.mainQueue,
                authenticator: $0.authenticator
            ) }
        )
)
