//
//  AppAction.swift
//  InstagramTV
//
//  Created by Igor Nazarov on 09.12.2021.
//

import Foundation

enum AppAction: Equatable {
    case loginButtonTapped
    case authenticationResponse(Result<String, AuthenticationClient.Error>)
}

struct ApiError: Error, Equatable {}
