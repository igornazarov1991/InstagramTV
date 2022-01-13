//
//  InitializationView.swift
//  InstagramTV
//
//  Created by Igor Nazarov on 14.12.2021.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            SwitchStore(store) {
                CaseLet(
                    state: /AppState.fetchSecret,
                    action: AppAction.fetchSecret
                ) { store in
                    FetchSecretView(store: store)
                }
                CaseLet(
                    state: /AppState.login,
                    action: AppAction.login
                ) { store in
                    LoginView(store: store)
                }
                CaseLet(
                    state: /AppState.loggedIn,
                    action: AppAction.loggedIn
                ) { store in
                    LoggedInView(store: store)
                }
            }
            .onAppear {
                viewStore.send(.fetchSecret(.fetchSecret))
            }
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(
            initialState: AppState(),
            reducer: appReducer,
            environment: .live
        )
        AppView(store: store)
    }
}
