//
//  LoggedInCore.swift
//  InstagramTV
//
//  Created by Igor Nazarov on 29.12.2021.
//

import Foundation
import Swiftagram
import ComposableArchitecture

struct LoggedInState: Equatable {
    var secret: Secret
    var profile: ProfileState?
}

enum LoggedInAction: Equatable {
    case onAppear
    case profile(ProfileAction)
}

struct LoggedInEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var userClient: UserClient

    static let live = Self(
        mainQueue: .main,
        userClient: .live
    )
}

let loggedInReducer = Reducer<
    LoggedInState,
    LoggedInAction,
    LoggedInEnvironment
>.combine(
    profileReducer
        .optional()
        .pullback(
            state: \.profile,
            action: /LoggedInAction.profile,
            environment: {
                ProfileEnvironment(
                    mainQueue: $0.mainQueue,
                    userClient: $0.userClient
                )
            }
        ),

    Reducer { state, action, _ in
        switch action {
        case .onAppear:
            state.profile = ProfileState(secret: state.secret)
            return .none

        case .profile:
            return .none
        }
    }
)
