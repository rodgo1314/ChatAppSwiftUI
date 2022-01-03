//
//  MessagesViewModel.swift
//  ChatAppSwiftUI
//
//  Created by Rodrigo Leyva on 11/10/21.
//

import Foundation
import SwiftUI

class MessagesViewModel: ObservableObject{
    
    @Published var messages: [FirestoreMessage] = []
    @Published var currentGroup: Group?
    
    
    
    func sendMessage(to group: Group, sentBy: User, messageText: String, completion: @escaping (Bool)-> Void ){
        let newMessage = FirestoreMessage(messageText: messageText, sentAt: Date(), sentByUser: sentBy)
        
        DatabaseManager.shared.sendMessage(group: group, message: newMessage, completion: completion)
    }
    func stopListeningToMessages(){
        DatabaseManager.shared.stopListeningToMessages()
    }
    
    func listenForAllMessages(group: Group){
        guard let groupID = group.id else {
            print("no group to listen to")
            return
        }
        

        DatabaseManager.shared.listenForAllMessages(groupID: groupID) { result in
            
            switch result{
            case .success(let messages):
                if self.messages.isEmpty{
                    withAnimation{
                        self.messages = messages.sorted {
                            $0.sentAt < $1.sentAt
                        }
                    }
                }else{
                    withAnimation{
                        self.messages.append(contentsOf: messages)
                        
                    }
                }
                
                
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
