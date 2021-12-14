//
//  ContentView.swift
//  InstagramTV
//
//  Created by Igor Nazarov on 09.12.2021.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text("\(viewStore.authentication.loginInfo)")
                Button("login") { viewStore.send(.authentication(.loginButtonTapped)) }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(
            initialState: .initial,
            reducer: appReducer,
            environment: .live
        )
        ContentView(store: store)
    }
}
