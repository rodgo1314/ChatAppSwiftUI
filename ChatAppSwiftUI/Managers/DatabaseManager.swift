//
//  DatabaseManager.swift
//  ChatAppSwiftUI
//
//  Created by Rodrigo Leyva on 11/9/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum DatabaseError: Error{
    case FailedFetch
    case FailedToDecode
    case NoUserID
}

class DatabaseManager{
    
    static let shared = DatabaseManager()
    
    let database = Firestore.firestore()
    
    var listenerForGroups: ListenerRegistration?
    
    var listenerForMessages: ListenerRegistration?
    
    func stopListeningToGroups(){
        if let listenerForGroups = listenerForGroups {
            listenerForGroups.remove()
        }
    }
    
    func stopListeningToMessages(){
        if let listenerForMessages = listenerForMessages {
            listenerForMessages.remove()
        }
    }
    
    func listenForAllGroups(for currentUser: User, completion: @escaping (Result<[Group],Error>)->Void){
        
        guard let currentUserID = currentUser.id else{
            completion(.failure(DatabaseError.NoUserID))
            return
        }
        
        listenerForGroups = database.collection("Groups").whereField("membersIDs", arrayContains: currentUserID).addSnapshotListener { snapShot, error in
            var groups: [Group] = []
            if let error = error{
                completion(.failure(error))
                return
            }
            guard let snapShot = snapShot else{
                completion(.failure(DatabaseError.FailedFetch))
                return
            }
            
            for doc in snapShot.documents{
                do{
                    guard let convo = try doc.data(as: Group.self) else {
                        completion(.failure(DatabaseError.FailedToDecode))
                        return
                    }
                    groups.append(convo)
                }catch{
                    completion(.failure(error))
                    return
                }
            }
            completion(.success(groups))
            
            
        }
        
    }
    func getAllGroupsForUser(for currentUser: User, completion: @escaping (Result<[Group],Error>)->Void){
        var groups: [Group] = []
        guard let currentUserID = currentUser.id else{
            completion(.failure(DatabaseError.NoUserID))
            return
        }
        
        database.collection("Groups").whereField("membersIDs", arrayContains: currentUserID).getDocuments { snapShot, error in
            
            if let error = error{
                completion(.failure(error))
                return
            }
            guard let snapShot = snapShot else{
                completion(.failure(DatabaseError.FailedFetch))
                return
            }
            
            for doc in snapShot.documents{
                do{
                    guard let convo = try doc.data(as: Group.self) else {
                        completion(.failure(DatabaseError.FailedToDecode))
                        return
                    }
                    groups.append(convo)
                }catch{
                    completion(.failure(error))
                    return
                }
            }
            completion(.success(groups))
            
            
        }
        
    }
    
    
    func listenForAllMessages(groupID: String, completion: @escaping (Result<[FirestoreMessage],Error>)-> Void){
        
        listenerForMessages = database.collection("Messages").document(groupID).collection("messages").addSnapshotListener { snapShot, error in
            var messages: [FirestoreMessage] = []
            if let error = error{
                completion(.failure(error))
                return
            }
            
            guard let snapShot = snapShot else {
                completion(.failure(DatabaseError.FailedFetch))
                return
            }
            
            snapShot.documentChanges.forEach{diff in
                if (diff.type == .added){
                    do{
                        guard let newMessage = try diff.document.data(as: FirestoreMessage.self) else {
                            completion(.failure(DatabaseError.FailedToDecode))
                            return
                        }
                        messages.append(newMessage)
                        
                    }catch{
                        completion(.failure(error))
                        return
                    }
                }
                
            }
            completion(.success(messages))
            return
            
            
            
            
        }
    }
    
    func createUser(id: String, user: User){
        do{
            try database.collection("Users").document(id).setData(from: user)
        }catch{
            print("error")
        }
        
    }
    func sendMessage(group: Group, message: FirestoreMessage, completion: @escaping (Bool)-> Void){
        
        guard let groupID = group.id else {
            print("no group id")
            completion(false)
            return
        }
        
        let updatedGroup = Group(id: groupID, createdAt: group.createdAt, createdBy: group.createdBy, members: group.members, recentMessage: message, membersIDs: group.membersIDs)
        
        do{
            let ref = try database.collection("Messages").document(groupID).collection("messages").addDocument(from: message)
            // now update the latest message
           try database.collection("Groups").document(groupID).setData(from: updatedGroup)
            print("sent message and updated latestMessage")
            completion(true)

        }catch{
            print(error)
            completion(false)
        }
    }
    
    func deleteGroup(with group: Group, completion: @escaping (Bool)-> Void){
        guard let groupID = group.id else {
            print("no group id to delete")
            completion(false)
            return
        }
        
        database.collection("Groups").document(groupID).delete()
        completion(true)
    }
    func createNewGroup(with user: User, createdBy: User, message: FirestoreMessage, completion: @escaping (Result<Group,Error>) -> Void){
        guard let userID = user.id, let createdByID = createdBy.id else{
            completion(.failure(DatabaseError.NoUserID))
            return
        }
        let newGroup = Group(createdAt: Date(), createdBy: createdBy, members: [user,createdBy], recentMessage: message, membersIDs: [userID,createdByID])
        do{
            let ref = try database.collection("Groups").addDocument(from: newGroup)
            ref.getDocument { snapShot, error in
                if let error = error{
                    completion(.failure(error))
                    return
                }
                guard let snapShot = snapShot else{
                    completion(.failure(DatabaseError.FailedFetch))
                    return
                }
                do{
                    guard let groupToReturn = try snapShot.data(as: Group.self) else {
                        completion(.failure(DatabaseError.FailedToDecode))
                        return
                    }
                    
                    //update groups list for each users
                    
                    completion(.success(groupToReturn))
                }catch{
                    completion(.failure(error))
                    return
                }
                
                
            }

        }catch{
            print(error)
            completion(.failure(error))
            return
        }
    }
    
    func getUser(id: String, completion: @escaping (Result<User,Error>)-> Void){
        
        database.collection("Users").document(id).getDocument { snapShot, error in
            if let error = error{
                completion(.failure(error))
                return
            }
            guard let snapShot = snapShot else{
                completion(.failure(DatabaseError.FailedFetch))
                return
            }
            
            do{
                guard let user = try snapShot.data(as: User.self) else{
                    completion(.failure(DatabaseError.FailedToDecode))
                    return
                }
                completion(.success(user))
                
            }catch{
                completion(.failure(error))
            }
        }
        
    }
    
    func getAllUsers(completion: @escaping (Result<[User],Error>)->Void){
        var users: [User] = []
        database.collection("Users").getDocuments { snapShot, error in
            
            if let error = error{
                completion(.failure(error))
                return
            }
            guard let snapShot = snapShot else{
                completion(.failure(DatabaseError.FailedFetch))
                return
            }
            
            for doc in snapShot.documents{
                do{
                    guard let user = try doc.data(as: User.self) else{
                        completion(.failure(DatabaseError.FailedToDecode))
                        return
                    }
                    users.append(user)
                }catch{
                    completion(.failure(error))
                    return
                }
            }
            
            completion(.success(users))
        }
    }
}
