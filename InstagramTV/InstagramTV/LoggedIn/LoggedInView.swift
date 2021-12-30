//
//  LoggedInView.swift
//  InstagramTV
//
//  Created by Igor Nazarov on 30.12.2021.
//

import SwiftUI
import ComposableArchitecture

struct LoggedInView: View {
    let store: Store<LoggedInState, LoggedInAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            TabView {
                IfLetStore(
                    store.scope(
                        state: \.profile,
                        action: LoggedInAction.profile
                    ),
                    then: ProfileView.init(store:)
                )
                    .tabItem {
                        Text("Profile")
                    }

                Text("Followers")
                    .tabItem { Text("Followers") }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}
