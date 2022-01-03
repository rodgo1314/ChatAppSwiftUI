//
//  User.swift
//  ChatAppSwiftUI
//
//  Created by Rodrigo Leyva on 11/9/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: Codable, Identifiable, Equatable{
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.userID == rhs.userID
    }
    
    @DocumentID var id: String?
    let displayName: String
    let email: String
    let groups: [Group]
    let photoURL: String
    var isCurrentUser: Bool = false
    let userID: String
    
}
