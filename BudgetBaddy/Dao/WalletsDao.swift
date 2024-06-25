//
//  WalletDao.swift
//  BudgetBaddy
//
//  Created by 柴田健作 on 2024/06/25.
//

import Foundation
import FirebaseFirestore

class WalletsDao {
    //　MARK: - Wallets
    static func addWallet(wallet: Wallet) {
        let db = Firestore.firestore()
        let walletRef = db.collection("Wallets").document(wallet.walletId)
        
        walletRef.setData(wallet.toDictionary()) { error in
            if let error = error {
                print("Error adding wallet: \(error)")
            } else {
                print("Wallet added successfully")
            }
        }
    }
    
    static func updateWallet(editedWallet: Wallet) {
        let db = Firestore.firestore()
        let walletRef = db.collection("Wallets").document(editedWallet.walletId)

        walletRef.updateData([
            "name": editedWallet.name,
            "is_default": editedWallet.is_default,
            "is_private": editedWallet.is_private,
            "sort_order": editedWallet.sort_order
        ]) { error in
            if let error = error {
                print("Error update Wallet: \(error)")
            } else {
                print("Update wallet successfully")
            }
        }
    }
    
    static func deleteWallet(wallet: Wallet, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let walletRef = db.collection("Wallets").document(wallet.walletId)

        walletRef.delete { error in
            if let error = error {
                print("Error deleting Wallet: \(error)")
                completion(error)
            } else {
                print("Wallet successfully deleted")
                completion(nil)
            }
        }
    }
    
    static func fetchWallet(walletId: String, completion: @escaping (Wallet?) -> Void) {
        let db = Firestore.firestore()
        let walletRef = db.collection("Wallets").document(walletId)

        walletRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let wallet = Wallet(dictionary: data!)
                completion(wallet)
            } else {
                print("Wallet not found")
                completion(nil)
            }
        }
    }
    
    //　MARK: - SharedUserInfo
    static func addSharedUserToWallet(walletId: String, newUser: User) {
        let db = Firestore.firestore()
        let walletRef = db.collection("Wallets").document(walletId)

        walletRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let newUserInfo = UserInfo(userId: newUser.userId, username: newUser.username)
                let newUserInfoData = newUserInfo.toDictionary()
                
                walletRef.updateData([
                        "sharedUsersInfo": FieldValue.arrayUnion([newUserInfoData])
                    ]) { error in
                        if let error = error {
                            print("Error adding sharedUser to Wallet: \(error)")
                        } else {
                            print("SharedUser added to wallet successfully")
                        }
                    }
            } else {
                print("Wallet document does not exist")
            }
        }
    }
    
    static func updateSharedUserInWallet(walletId: String, editedUserInfo: UserInfo) {
        let db = Firestore.firestore()
        let walletRef = db.collection("Wallets").document(walletId)

        let editedUserInfoData = editedUserInfo.toDictionary()

        walletRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var currentData = document.data()!
                var sharedUsersInfo = currentData["sharedUsersInfo"] as! [[String: Any]]
                
                if let index = sharedUsersInfo.firstIndex(where: { $0["userId"] as? String == editedUserInfo.userId }) {
                    sharedUsersInfo[index] = editedUserInfoData
                } else {
                    print("UserInfo not found")
                    return
                }
                
                // Firestoreドキュメントを更新
                walletRef.updateData([
                    "sharedUsersInfo": sharedUsersInfo
                ]) { error in
                    if let error = error {
                        print("Error updating UserInfo in Wallet: \(error)")
                    } else {
                        print("UserInfo updated in Wallet successfully")
                    }
                }
            } else {
                print("Wallet document does not exist")
            }
        }
    }
    
    static func removeSharedUserFromWallet(walletId: String, userInfo: UserInfo) {
        let db = Firestore.firestore()
        let walletRef = db.collection("Wallets").document(walletId)

        let userInfoData = userInfo.toDictionary()

        // FieldValue.arrayRemoveを使用してsharedUsersInfo配列からUserInfoを削除
        walletRef.updateData([
            "sharedUsersInfo": FieldValue.arrayRemove([userInfoData])
        ]) { error in
            if let error = error {
                print("Error removing userInfo from Wallet: \(error)")
            } else {
                print("UserInfo removed from wallet successfully")
            }
        }
    }
    
    //　MARK: - Category
    static func addCategoryToWallet(walletId: String, newCategory: Category) {
        let db = Firestore.firestore()
        let walletRef = db.collection("Wallets").document(walletId)
        
        let newCategoryData = newCategory.toDictionary()

        walletRef.getDocument { (document, error) in
            if let document = document, document.exists {
                walletRef.updateData([
                        "categories": FieldValue.arrayUnion([newCategoryData])
                    ]) { error in
                        if let error = error {
                            print("Error adding category to Wallet: \(error)")
                        } else {
                            print("Category added to wallet successfully")
                        }
                    }
            } else {
                print("Wallet document does not exist")
            }
        }
    }
    
    static func updateCategoryInWallet(walletId: String, editedCategory: Category) {
        let db = Firestore.firestore()
        let walletRef = db.collection("Wallets").document(walletId)

        let editedCategoryData = editedCategory.toDictionary()

        walletRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var currentData = document.data()!
                var categories = currentData["categories"] as! [[String: Any]]
                
                if let index = categories.firstIndex(where: { $0["categoryId"] as? String == editedCategory.categoryId }) {
                    categories[index] = editedCategoryData
                } else {
                    print("Category not found")
                    return
                }
                
                // Firestoreドキュメントを更新
                walletRef.updateData([
                    "goals": categories
                ]) { error in
                    if let error = error {
                        print("Error updating category in Wallet: \(error)")
                    } else {
                        print("Category updated in Wallet successfully")
                    }
                }
            } else {
                print("Wallet document does not exist")
            }
        }
    }
    
    static func removeCategoryFromWallet(walletId: String, category: Category) {
        let db = Firestore.firestore()
        let walletRef = db.collection("Wallets").document(walletId)

        let categoryData = category.toDictionary()

        // FieldValue.arrayRemoveを使用してsharedUsersInfo配列からUserInfoを削除
        walletRef.updateData([
            "categories": FieldValue.arrayRemove([categoryData])
        ]) { error in
            if let error = error {
                print("Error removing category from Wallet: \(error)")
            } else {
                print("Category removed from wallet successfully")
            }
        }
    }
}
