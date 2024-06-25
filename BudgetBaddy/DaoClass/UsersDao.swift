//
//  UsersDao.swift
//  BudgetBaddy
//
//  Created by 柴田健作 on 2024/06/23.
//

import FirebaseFirestore

class UsersDao {
    static func fetchUserData(userId: String) async -> User? {
        let db = Firestore.firestore()
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            guard let data = document.data() else {
                return nil
            }
            return User(dictionary: data)
        } catch {
            return nil
        }
    }
    
    static func saveUserData(userId: String, email: String, username: String) async -> Bool {
        let db = Firestore.firestore()
        do {
            let ref: Void = try await db.collection("users").document(userId).setData([
                "userId": userId,
                "email": email,
                "username": username,
                "created_at": Timestamp(date: Date())
            ])
            return true
        } catch {
            return false
        }
    }
}
