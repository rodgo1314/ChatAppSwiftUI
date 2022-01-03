//
//  MakeNewConvoView.swift
//  ChatAppSwiftUI
//
//  Created by Rodrigo Leyva on 11/9/21.
//

import SwiftUI

struct MakeNewConvoView: View {
    @State var userToSearch: String = ""
    @State var searching = false
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var chatViewModel: ConversationsViewModel


    
    var body: some View {
        ZStack {
            VStack(alignment: .leading){
                SearchBar(userToSearch: $userToSearch, searching: $searching)
                ForEach(chatViewModel.searchedUsers){user in
                    NavigationLink(isActive: $chatViewModel.isNewGroup) {
                        
                        MessageView(user: user)
                    } label: {
                        Text(user.displayName)
                            .padding()
                    }
                    
                    
                }
                Spacer()
                    .navigationBarTitle("Search Users")
                    .toolbar {
                        if searching{
                            Button {
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Text("Cancel")
                            }

                        }
                    }
                
            }
            if chatViewModel.isLoading{
                ProgressView("Loading...")
            }
        }
        
    }
}


struct MakeNewConvoView_Previews: PreviewProvider {
    static var previews: some View {
        MakeNewConvoView()
    }
}
