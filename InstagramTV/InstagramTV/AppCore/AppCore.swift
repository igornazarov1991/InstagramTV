//
//  AppCore.swift
//  InstagramTV
//
//  Created by Igor Nazarov on 29.12.2021.
//

import Foundation
import CombineSchedulers
import ComposableArchitecture
import Swiftagram

enum AppState: Equatable {
    case fetchSecret(FetchSecretState)
    case login(LoginState)
    case loggedIn(LoggedInState)

    init() { self = .fetchSecret(.init()) }
}

enum AppAction: Equatable {
    case fetchSecret(FetchSecretAction)
    case login(LoginAction)
    case loggedIn(LoggedInAction)
}

struct AppEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var fetchSecretClient: FetchSecretClient
    var authenticationClient: AuthenticationClient
    var userClient: UserClient

    static let live = Self(
        mainQueue: .main,
        fetchSecretClient: .live,
        authenticationClient: .live,
        userClient: .live
    )
}

#if DEBUG
extension AppEnvironment {
    static let test = Self(
        mainQueue: .immediate,
        fetchSecretClient: .test,
        authenticationClient: .test,
        userClient: .test
    )
}
#endif

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    fetchSecretReducer.pullback(
        state: /AppState.fetchSecret,
        action: /AppAction.fetchSecret,
        environment: {
            FetchSecretEnvironment(
                mainQueue: $0.mainQueue,
                fetchSecretClient: $0.fetchSecretClient
            )
        }
    ),

    loginReducer.pullback(
        state: /AppState.login,
        action: /AppAction.login,
        environment: {
            LoginEnvironment(
                mainQueue: $0.mainQueue,
                authenticationClient: $0.authenticationClient
            )
        }
    ),

    loggedInReducer.pullback(
        state: /AppState.loggedIn,
        action: /AppAction.loggedIn,
        environment: {
            LoggedInEnvironment(
                mainQueue: $0.mainQueue,
                userClient: $0.userClient
            )
        }
    ),

    Reducer { state, action, _ in
        switch action {
        case .fetchSecret(.fetchSecretResponse(.success(let secret))):
            state = .loggedIn(.init(secret: secret))
            return .none

        case .fetchSecret(.fetchSecretResponse(.failure(let error))):
            state = .login(.init())
            return .none

        case .fetchSecret:
            return .none

        case .login(.loginResponse(.success(let secret))):
            state = .loggedIn(.init(secret: secret))
            return .none

        case .login(.twoFactorResponse(.success(let secret))):
            state = .loggedIn(.init(secret: secret))
            return .none

        case .login:
            return .none

        case .loggedIn:
            return .none
        }
    }
)
