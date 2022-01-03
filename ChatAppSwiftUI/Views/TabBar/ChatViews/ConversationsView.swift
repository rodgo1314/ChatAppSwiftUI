//
//  ChatView.swift
//  ChatAppSwiftUI
//
//  Created by Rodrigo Leyva on 11/9/21.
//

import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

struct ConversationsView: View {
    @State var makeNewConvo:Bool = false
    @EnvironmentObject var conversationsViewModel: ConversationsViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var searching = false
    @State var userToSearch: String = ""
    @State var shouldTransition = false
    
    
    var body: some View {
        ZStack {
        
            if searching{
                VStack(alignment: .leading){
                    SearchBar(userToSearch: $userToSearch, searching: $searching)
                    ForEach(conversationsViewModel.searchedUsers){user in
                        NavigationLink {
                            
                            MessageView(user: user, group: nil)
                                .environmentObject(conversationsViewModel)
                            
                            
                        } label: {
                            Text(user.displayName)
                                .padding()
                            
                        }
                    }
                    
                    Spacer()
                    
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitle("New Message")
                
                .toolbar {
                    if searching{
                        Button {
                            withAnimation{
                                searching = false
                            }

                        } label: {
                            Text("Cancel")
                        }
                        
                    }
                }
                
            }else{
                VStack(spacing: 40){
                    List{
                        ForEach(conversationsViewModel.groups){group in
                            
                            if #available(iOS 15.0, *) {
                                NavigationLink {
                                    
                                    MessageView(user:  nil,group: group)
                                        .environmentObject(conversationsViewModel)
                                    
                                }label: {
                                    GroupCell(group: group)
                                }
                                
                                .swipeActions{
                                    Button {
                                        // delete group from database
                                        conversationsViewModel.deleteGroup(with: group){ success in
                                            
                                            if success {
                                                print("delete success ful ")
                                            }
                                        }
                                        
                                    } label: {
                                        Text("Delete")
                                    }
                                    .tint(.red)
                                    
                                }
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                        .frame(maxHeight: 120)
                        

                    }
                    
                }
                .navigationBarTitleDisplayMode(.large)
                .navigationBarTitle("Messages")
                .toolbar {
                    Button {
                        withAnimation{
                            searching = true
                        }
                        
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                    
                    
                }
            }
            
            
            if conversationsViewModel.isLoading{
                ProgressView("Loading...")
            }
        }
        
    }
        
    
    
}

struct SearchBar: View{
    @Binding var userToSearch: String
    @Binding var searching: Bool
    @EnvironmentObject var chatViewModel: ConversationsViewModel
    
    var body: some View{
        ZStack {
            Rectangle()
                .foregroundColor(Color(UIColor.lightGray))
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white)
                TextField("Search ..", text: $userToSearch){ startedEditing in
                    if startedEditing{
                        
                        searching = true
                    }
                    
                }onCommit: {
                    print(userToSearch)
                    //call database to search users
                    chatViewModel.searchUsersAndFilter(with: userToSearch)
                    
                }
                .foregroundColor(.white)
                
                
            }
            .foregroundColor(.gray)
            .padding(.leading, 13)
        }
        .frame(height: 40)
        .cornerRadius(13)
        .padding()
    }
}



struct GroupCell: View{
    var group: Group
    @EnvironmentObject var chatViewModel: ConversationsViewModel
    var body: some View{
        HStack(alignment: .top, spacing: 15) {
            WebImage(url: URL(string: imageToPresent()))
                .resizable()
                .frame(width: 100, height: 100, alignment: .center)
                .cornerRadius(30)
            VStack(alignment: .leading){
                Text(nameToPresent())
                    .font(.title)
                Text(group.recentMessage.messageText)
                    .font(.title3)
                    .truncationMode(.tail)
            }
        }
        
    }

    
    
    func imageToPresent() -> String{
        var urlString: String = ""
        guard let currentUserID = chatViewModel.currentUser?.userID else {
            print("no current user")
            return ""
        }
        for user in group.members{
            if user.userID != currentUserID{
                urlString = user.photoURL
            }
               
        }
        
        return urlString
    }
    func nameToPresent()-> String{
        guard let currentUserID = chatViewModel.currentUser?.userID else {
            print("no current user")
            return ""
        }
        var name: String = ""
        for user in group.members{
            if user.userID != currentUserID{
                name = user.displayName
                
            }
        }
        
        return name
    }
    
}
