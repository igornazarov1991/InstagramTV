//
//  AppState.swift
//  InstagramTV
//
//  Created by Igor Nazarov on 09.12.2021.
//

import Foundation

struct AppState: Equatable {
    var authentication: AuthenticationState

    static let initial = Self(
        authentication: .initial
    )
}
