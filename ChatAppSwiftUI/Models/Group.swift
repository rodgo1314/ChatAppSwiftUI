//
//  Group.swift
//  ChatAppSwiftUI
//
//  Created by Rodrigo Leyva on 11/9/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Group: Codable, Identifiable{
    @DocumentID var id: String?
    let createdAt: Date
    let createdBy: User
    let members: [User]
    let recentMessage: FirestoreMessage
    let membersIDs: [String]
    
}
