//
//  InstagramTVApp.swift
//  InstagramTV
//
//  Created by Igor Nazarov on 09.12.2021.
//

import SwiftUI
import ComposableArchitecture

@main
struct InstagramTVApp: App {
    var body: some Scene {
        WindowGroup {
            let store = Store(
                initialState: AppState(),
                reducer: appReducer,
                environment: .live
            )
            AppView(store: store)
        }
    }
}
