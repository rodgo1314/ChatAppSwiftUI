//
//  MessageView.swift
//  ChatAppSwiftUI
//
//  Created by Rodrigo Leyva on 11/9/21.
//

import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

struct MessageView: View {
    @StateObject var messagesViewModel = MessagesViewModel()
    @EnvironmentObject var conversationsViewModel: ConversationsViewModel
    @State var typingMessage: String = ""
    
    init(user: User?, group: Group?){
        self.user = user
        self.group = group
        
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().separatorColor = .clear
        UITableView.appearance().tableFooterView = UIView()
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        
    }
    var user: User?
    var group: Group?
    @State var otherPersonName: String = "Message"
    var body: some View {
        
        VStack(alignment: .leading) {
            ScrollViewReader { value in
                List {
                    ForEach(messagesViewModel.messages) { msg in
                        OtherMessageView(currentMessage: msg)
                            .environmentObject(conversationsViewModel)
                    }
                    .onAppear{
                        value.scrollTo(messagesViewModel.messages.last?.id, anchor: .center)
                    }
                    .onChange(of: messagesViewModel.messages.count){ _ in
                        value.scrollTo(messagesViewModel.messages.last?.id, anchor: .center)
                        
                    }
                }
            }
            
            
            
            
            HStack {
                TextField("Message...", text: $typingMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: CGFloat(30))
                Button {
                    //Send message to user in chat
                    if let user = user, let currentUser = conversationsViewModel.currentUser {
                        //if user exists we are coming from new convo
                        //start a new convo and send message
                        conversationsViewModel.createNewGroup(with: user, createdBy: currentUser, message: typingMessage) { result in
                            switch result{
                            case .success(let group):
                                //send new message to this group
                                print(group.id)
                                messagesViewModel.sendMessage(to: group, sentBy: currentUser, messageText: typingMessage) { success in
                                    if success{
                                        //show alert
                                        print("message sent will now start listening from new group")
                                        messagesViewModel.listenForAllMessages(group: group)
                                        self.typingMessage = ""
                                        
                                    }
                                }
                                
                            case .failure(let error):
                                //show alert of failing to create new group
                                print(error)
                            }
                        }
                    }
                    else if let group = group, let currentUser = conversationsViewModel.currentUser {
                        // we are coming from an existing convo
                        //send a regular message
                        messagesViewModel.sendMessage(to: group, sentBy: currentUser, messageText: typingMessage) { success in
                            if success{
                                // show alert
                                print("message sent from click on user")
                                self.typingMessage = ""
                                
                            }
                        }
                    }
                    
                    
                    
                } label: {
                    Text("Send")
                }
                
            }.frame(minHeight: CGFloat(50)).padding()
        }
        .navigationBarTitle(otherPersonName, displayMode: .inline)
        .onAppear{
            
            if let group = group, let currentUserID = conversationsViewModel.currentUser?.userID {
                messagesViewModel.listenForAllMessages(group: group)
                group.members.forEach{ mem in
                    if mem.userID != currentUserID{
                        self.otherPersonName = mem.displayName
                    }
                }
            }else if let user = user {
                self.otherPersonName = user.displayName
            }
        }
        .onDisappear{
            //stop listening to messages
            messagesViewModel.stopListeningToMessages()
            
        }
    }
    
}

struct SenderMessageView: View{
    @EnvironmentObject var conversationsViewModel: ConversationsViewModel
    
    var contentMessage: FirestoreMessage
    
    var body: some View{
        Text(contentMessage.messageText)
            .padding(10)
            .foregroundColor(Color.white)
            .background(contentMessage.sentByUser == conversationsViewModel.currentUser ? Color.blue : Color.gray)
            .cornerRadius(10)
    }
}

struct OtherMessageView: View{
    @EnvironmentObject var conversationsViewModel: ConversationsViewModel
    var currentMessage: FirestoreMessage
    
    var body: some View{
        HStack(alignment: .bottom, spacing: 15) {
            if currentMessage.sentByUser != conversationsViewModel.currentUser {
                WebImage(url: URL(string: currentMessage.sentByUser.photoURL))
                    .resizable()
                    .frame(width: 40, height: 40, alignment: .center)
                    .cornerRadius(20)
                
                
                
            } else {
                Spacer()
            }
            SenderMessageView(contentMessage: currentMessage)
        }
    }
}


