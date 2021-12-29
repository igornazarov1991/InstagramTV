//
//  LoggedInCore.swift
//  InstagramTV
//
//  Created by Igor Nazarov on 29.12.2021.
//

import Foundation
import Swiftagram

struct LoggedInState: Equatable {
    var secret: Secret
}

enum LoggedInAction: Equatable {}

struct LoggedInEnvironment {
    init() {}
}
