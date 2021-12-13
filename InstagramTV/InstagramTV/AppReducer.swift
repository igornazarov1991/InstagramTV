//
//  AppReducer.swift
//  InstagramTV
//
//  Created by Igor Nazarov on 09.12.2021.
//

import Foundation
import ComposableArchitecture
import Swiftagram

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case .loginButtonTapped:
        return environment.authenticator.authenticate(state.username, state.password)
            .receive(on: environment.mainQueue)
            .catchToEffect(AppAction.authenticationResponse)

    case .authenticationResponse(.success(let secret)):
        state.secret = secret
        return .none

    case .authenticationResponse(.failure(let error)):
        return .none
    }
}
