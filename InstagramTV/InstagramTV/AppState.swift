//
//  AppState.swift
//  InstagramTV
//
//  Created by Igor Nazarov on 09.12.2021.
//

import Foundation

struct AppState: Equatable {
    var username = ""
    var password = ""
    var secret = ""

    static let initial = Self(
        username: "igor.nazarov.1991",
        password: "password",
        secret: ""
    )
}
