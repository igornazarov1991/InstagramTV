//
//  ProfileCore.swift
//  InstagramTV
//
//  Created by Igor Nazarov on 30.12.2021.
//

import Foundation
import Swiftagram
import ComposableArchitecture

struct ProfileState: Equatable {
    var secret: Secret
    var currentUser: User?
}

enum ProfileAction: Equatable {
    case fetchCurrentUser
    case fetchCurrentUserResponse(Result<User?, UserClient.Error>)
}

struct ProfileEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var userClient: UserClient

    static let live = Self(
        mainQueue: .main,
        userClient: .live
    )
}

let profileReducer = Reducer<
    ProfileState,
    ProfileAction,
    ProfileEnvironment
> { state, action, environment in
    switch action {
    case .fetchCurrentUser:
        return environment.userClient.fetchCurrentUser(state.secret)
            .receive(on: environment.mainQueue)
            .catchToEffect(ProfileAction.fetchCurrentUserResponse)

    case .fetchCurrentUserResponse(.success(let user)):
        state.currentUser = user
        return .none

    case .fetchCurrentUserResponse(.failure(let error)):
        print(error)
        return .none
    }
}
