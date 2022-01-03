//
//  ProfileView.swift
//  ChatAppSwiftUI
//
//  Created by Rodrigo Leyva on 11/9/21.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @EnvironmentObject var conversationsViewModel: ConversationsViewModel

    var body: some View {
        Text(conversationsViewModel.currentUser?.displayName ?? "Welcome" )
            .navigationBarTitle("My Profile")
            .toolbar {
                Button {
                    print("log out")
                    loginViewModel.signOut()
                } label: {
                    Text("Logout")
                }
            }
    }
}

