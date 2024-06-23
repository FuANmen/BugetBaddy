//
//  UserInfo.swift
//  BudgetBaddy
//
//  Created by 柴田健作 on 2024/06/23.
//

import Foundation
import FirebaseFirestoreInternal

class User {
    var userId: String
    var username: String
    var email: String
    var createdAt: Date
    
    init(userId: String, username: String, email: String, createdAt: Date) {
        self.userId = userId
        self.username = username
        self.email = email
        self.createdAt = createdAt
    }
    
    init?(dictionary: [String: Any]) {
        guard let userId = dictionary["userId"] as? String,
              let username = dictionary["username"] as? String,
              let email = dictionary["email"] as? String,
              let timestamp = dictionary["created_at"] as? Timestamp else {
            return nil
        }
        self.userId = userId
        self.username = username
        self.email = email
        self.createdAt = timestamp.dateValue()
    }
}
