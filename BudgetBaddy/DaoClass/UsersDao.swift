//
//  UsersDao.swift
//  BudgetBaddy
//
//  Created by 柴田健作 on 2024/06/23.
//

import FirebaseFirestore

class UsersDao {
    static func fetchUser(userId: String) async -> User? {
        let db = Firestore.firestore()
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            guard let data = document.data() else {
                return nil
            }
            print(data)
            return User(dictionary: data)
        } catch {
            return nil
        }
    }
    
    static func saveUser(userId: String, email: String, username: String) async -> Bool {
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
    
    static func updateUser(updateUser: User) {
        let db = Firestore.firestore()
        let walletRef = db.collection("Users").document(updateUser.userId)

        walletRef.updateData([
            "userId": updateUser.userId,
            "username": updateUser.username,
            "email": updateUser.email,
            "createdAt": updateUser.createdAt
        ]) { error in
            if let error = error {
                print("Error update Wallet: \(error)")
            } else {
                print("Update wallet successfully")
            }
        }
    }
    
    // SharedWalletId
    static func addSharedWalletIdToUser(userId: String, walletId: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(userId)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                
                userRef.updateData([
                    "sharedWalletId": FieldValue.arrayUnion([walletId])
                ]) { error in
                    if let error = error {
                        print("Error adding sharedWalletId to User: \(error)")
                    } else {
                        print("SharedWalletId added to user successfully")
                    }
                }
            } else {
                print("User document does not exist")
            }
        }
    }
    
    static func removeSharedWalletIdFromUser(userId: String, walletId: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(walletId)

        userRef.updateData([
            "sharedWalletId": FieldValue.arrayRemove([walletId])
        ]) { error in
            if let error = error {
                print("Error removing sharedWalletId from User: \(error)")
            } else {
                print("SharedWalletId removed from User successfully")
            }
        }
    }
}
