//
//  LoginView.swift
//  InstagramTV
//
//  Created by Igor Nazarov on 14.12.2021.
//

import SwiftUI
import ComposableArchitecture

struct LoginView: View {
    let store: Store<AppState, AppAction>

    @State var twoFactorCode = ""

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Color.white
                VStack {
                    Button("Login") { viewStore.send(.authentication(.loginButtonTapped)) }
                    if viewStore.authentication.twoFactorNeeded {
                        TextField(
                            "Enter code...",
                            text: $twoFactorCode
                        )
                            .foregroundColor(.red)
                        Button("Send code") { viewStore.send(.authentication(.sendTwoFactor(code: twoFactorCode))) }
                    }
                }
            }

        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(
            initialState: .initial,
            reducer: appReducer,
            environment: .live
        )
        LoginView(store: store)
    }
}
