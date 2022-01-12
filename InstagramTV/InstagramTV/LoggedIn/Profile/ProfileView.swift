//
//  LoggedInView.swift
//  InstagramTV
//
//  Created by Igor Nazarov on 29.12.2021.
//

import SwiftUI
import ComposableArchitecture
import Swiftagram

struct ProfileView: View {
    let store: Store<ProfileState, ProfileAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                if let thumbnail = viewStore.currentUser?.avatar {
                    AsyncImage(url: thumbnail)
                        .clipShape(Circle())
                }
                if let username = viewStore.currentUser?.username {
                    Text(username)
                }
            }
                .onAppear {
                    viewStore.send(.fetchCurrentUser)
                }
        }
    }
}
