//
//  FirestoreMessage.swift
//  ChatAppSwiftUI
//
//  Created by Rodrigo Leyva on 11/9/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct FirestoreMessage: Codable, Identifiable{
    @DocumentID var id: String?
    let messageText: String
    let sentAt: Date
    let sentByUser: User
    
}
