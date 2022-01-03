//
//  ChatViewModel.swift
//  ChatAppSwiftUI
//
//  Created by Rodrigo Leyva on 11/9/21.
//

import Foundation
import SwiftUI
import FirebaseAuth

class ConversationsViewModel: ObservableObject{
    
    @Published var groups: [Group] = []
    @Published var searchedUsers: [User] = []
    @Published var isLoading: Bool = false
    @Published var currentUser: User?
    @Published var isNewGroup: Bool = true
    
    
    
    func stopListeningToGroups(){
        DatabaseManager.shared.stopListeningToGroups()
    }
    
    

    func listenForAllGroupsForUser(){
        
        if let currentUser = currentUser {
            isLoading = true
            DatabaseManager.shared.listenForAllGroups(for: currentUser) { result in
                self.isLoading = false
                switch result{
                case .success(let groups):
                    self.groups = groups
                case.failure(let error):
                    print(error)
                }
            }
        }else{
            if let currentUserID = UserDefaults.standard.value(forKey: "uid") as? String {
                print(currentUserID)
                DatabaseManager.shared.getUser(id: currentUserID) { result in
                    switch result{
                    case .success(let user):
                        self.currentUser = user
                        self.listenForAllGroupsForUser()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            } else if let userID = Auth.auth().currentUser?.uid{
                print(userID)
                DatabaseManager.shared.getUser(id: userID) { result in
                    switch result{
                    case .success(let user):
                        self.currentUser = user
                        self.listenForAllGroupsForUser()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }

        
        
        
    }
    
    func deleteGroup(with group: Group, completion: @escaping (Bool)-> Void){
        DatabaseManager.shared.deleteGroup(with: group, completion: completion)
    }
    func getAllGroupsForUser(){
        guard let currentUser = currentUser else {
            print("No current user to listen for groups")
            return
        }

        
        DatabaseManager.shared.getAllGroupsForUser(for: currentUser) { result in
            switch result{
            case .success(let groups):
                self.groups = groups
            case.failure(let error):
                print(error)
            }
        }
        
    }
    func createNewGroup(with user: User, createdBy: User, message: String, completion: @escaping (Result<Group,Error>)-> Void){
        let messageToSend = FirestoreMessage(messageText: message, sentAt: Date(), sentByUser: createdBy)

        DatabaseManager.shared.createNewGroup(with: user, createdBy: createdBy, message: messageToSend, completion: completion)
        
    }
    
    
    func getCurrentUser(){
        
        if let currentUserID = UserDefaults.standard.value(forKey: "uid") as? String {
            print(currentUserID)
            DatabaseManager.shared.getUser(id: currentUserID) { result in
                switch result{
                case .success(let user):
                    self.currentUser = user
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        } else if let userID = Auth.auth().currentUser?.uid{
            UserDefaults.standard.set(userID, forKey: "uid")
            print(userID)
            DatabaseManager.shared.getUser(id: userID) { result in
                switch result{
                case .success(let user):
                    self.currentUser = user
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        
        
    }
    
    func searchUsersAndFilter(with nameToSearch: String){
        isLoading = true
        
        DatabaseManager.shared.getAllUsers { result in
            self.isLoading = false
            switch result{
            case .success(let users):
                var results: [User] = []
                for user in users{
                    let name = user.displayName.lowercased()
                    if self.currentUser != user && name.hasPrefix(nameToSearch.lowercased()) {
                        results.append(user)
                    }
                    
                }
                
                
                
                self.searchedUsers = results
                
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    
    
}
