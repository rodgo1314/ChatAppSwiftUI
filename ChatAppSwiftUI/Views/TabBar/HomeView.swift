//
//  HomeView.swift
//  ChatAppSwiftUI
//
//  Created by Rodrigo Leyva on 11/9/21.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @EnvironmentObject var chatViewModel: ConversationsViewModel
    
    @State var isLoadingConvos = false
    var body: some View {
        
        
        TabView{
            NavigationView{
                ConversationsView()
                    .onAppear{
                        chatViewModel.listenForAllGroupsForUser()
                    }
                    .onDisappear{
                        chatViewModel.stopListeningToGroups()
                    }
                
            }
            .tag(0)
            .tabItem {
                Label("Chats", systemImage: "message.fill")
            }
        
            NavigationView{
                ProfileView()
            }
            .tag(1)
            .tabItem {
                Label(chatViewModel.currentUser?.displayName ?? "Profile", systemImage: "person.circle")
            }
            
        }
        
        
        
        
    }
    
}

