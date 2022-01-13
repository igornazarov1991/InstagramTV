//
//  FetchSecretCore.swift
//  InstagramTV
//
//  Created by Igor Nazarov on 13.01.2022.
//

import Foundation
import Swiftagram
import ComposableArchitecture

struct FetchSecretState: Equatable { }

enum FetchSecretAction: Equatable {
    case fetchSecret
    case fetchSecretResponse(Result<Secret, FetchSecretClient.Error>)
}

struct FetchSecretEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var fetchSecretClient: FetchSecretClient

    static let live = Self(
        mainQueue: .main,
        fetchSecretClient: .live
    )
}

let fetchSecretReducer = Reducer<
    FetchSecretState,
    FetchSecretAction,
    FetchSecretEnvironment
> { _, action, environment in
    switch action {
    case .fetchSecret:
        return environment.fetchSecretClient.fetchSecret()
            .receive(on: environment.mainQueue)
            .catchToEffect(FetchSecretAction.fetchSecretResponse)

    case .fetchSecretResponse(.success(let secret)):
        return .none

    case .fetchSecretResponse(.failure(let error)):
        return .none
    }
}
