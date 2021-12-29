//
//  LoginView.swift
//  InstagramTV
//
//  Created by Igor Nazarov on 14.12.2021.
//

import SwiftUI
import ComposableArchitecture

struct LoginView: View {
    let store: Store<LoginState, LoginAction>

    @State var twoFactorCode = ""

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Color.white
                VStack {
                    Button("Login") { viewStore.send(.loginButtonTapped) }
                    if viewStore.twoFactorChallenge != nil {
                        TextField(
                            "Enter code...",
                            text: $twoFactorCode
                        )
                            .foregroundColor(.red)
                        Button("Send code") { viewStore.send(.sendTwoFactor(code: twoFactorCode)) }
                    }
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(
            store: Store(
                initialState: LoginState(),
                reducer: loginReducer,
                environment: .live
            )
        )
    }
}
