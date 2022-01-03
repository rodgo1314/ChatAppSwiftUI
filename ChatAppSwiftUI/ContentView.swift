//
//  ContentView.swift
//  ChatAppSwiftUI
//
//  Created by Rodrigo Leyva on 11/9/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject var loginViewModel = LoginViewModel()
    @StateObject var chatViewModel = ConversationsViewModel()
    var body: some View {
        ZStack{
            
            if loginViewModel.loggedIn{
                
                HomeView()
                    .environmentObject(loginViewModel)
                    .environmentObject(chatViewModel)
                
            }else{
                NavigationView{
                    LoginView()
                }
                .environmentObject(loginViewModel)
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
