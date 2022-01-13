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
        ProgressView()
    }
}

struct FetchSecretView_Previews: PreviewProvider {
    static var previews: some View {
        FetchSecretView(
            store: Store(
                initialState: .init(),
                reducer: .empty,
                environment: ()
            )
        )
    }
}
