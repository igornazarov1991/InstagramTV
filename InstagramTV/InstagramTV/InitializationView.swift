//
//  InitializationView.swift
//  InstagramTV
//
//  Created by Igor Nazarov on 14.12.2021.
//

import SwiftUI
import ComposableArchitecture

struct InitializationView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            Text("Initialization...")
                .fullScreenCover(isPresented:
                                    viewStore.binding(
                                        get: \.authentication.isLoginPresented,
                                        send: .authentication(.setLoginSheet(presented: true))
                                    )
                ) {
                    LoginView()
                }
                .onAppear {
                    viewStore.send(.authentication(.fetchSecretToken))
                }
        }
    }
}

struct InitializationView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(
            initialState: .initial,
            reducer: appReducer,
            environment: .live
        )
        InitializationView(store: store)
    }
}
