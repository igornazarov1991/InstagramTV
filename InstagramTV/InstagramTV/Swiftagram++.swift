//
//  Swiftagram++.swift
//  InstagramTV
//
//  Created by Igor Nazarov on 29.12.2021.
//

import Foundation
import Swiftagram

typealias TwoFactor = Authenticator.Error.TwoFactor

extension TwoFactor: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

extension Secret: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.client == rhs.client &&
        lhs.identifier == rhs.identifier &&
        lhs.label == rhs.label
    }
}

extension User: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
