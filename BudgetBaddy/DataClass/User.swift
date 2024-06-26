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
    var sharedWalletIds: [String]
    
    init(userId: String, username: String, email: String, createdAt: Date, sharedWalletIds: [String]) {
        self.userId = userId
        self.username = username
        self.email = email
        self.createdAt = createdAt
        self.sharedWalletIds = sharedWalletIds
    }
    
    init?(dictionary: [String: Any]) {
        guard let userId = dictionary["userId"] as? String,
              let username = dictionary["username"] as? String,
              let email = dictionary["email"] as? String,
              let timestamp = dictionary["created_at"] as? Timestamp,
              let sharedWalletIds = dictionary["sharedWalletIds"] as? [String] else {
            return nil
        }
        self.userId = userId
        self.username = username
        self.email = email
        self.createdAt = timestamp.dateValue()
        self.sharedWalletIds = sharedWalletIds
    }
    
    internal func fetchWalletsForUser() async -> [Wallet] {
        do {
            let wallets = try await WalletsDao.fetchWalletsForUser(userId: self.userId, sharedWalletIds: self.sharedWalletIds)
            return wallets
        } catch {
            return []
        }
    }
}
