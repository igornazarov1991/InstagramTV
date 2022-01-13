//
//  FetchSecretView.swift
//  InstagramTV
//
//  Created by Igor Nazarov on 13.01.2022.
//

import SwiftUI
import ComposableArchitecture

struct FetchSecretView: View {
    let store: Store<FetchSecretState, FetchSecretAction>

    var body: some View {
        Text("Fetching secret...")
    }
}

struct FetchSecretView_Previews: PreviewProvider {
    static var previews: some View {
        FetchSecretView(
            store: Store(
                initialState: FetchSecretState(),
                reducer: fetchSecretReducer,
                environment: .live
            )
        )
    }
}
