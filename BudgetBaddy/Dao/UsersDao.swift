//
//  UsersDao.swift
//  BudgetBaddy
//
//  Created by 柴田健作 on 2024/06/23.
//

import FirebaseFirestore

class UsersDao {
    static func fetchUserData(userId: String, completion: @escaping (User?) -> Void){
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { (document, error) in
            if let error = error {
                print("ユーザーデータの取得に失敗しました: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let document = document, document.exists, var data = document.data() else {
                print("ユーザーデータが見つかりませんでした")
                completion(nil)
                return
            }
            
            data["userId"] = userId
            completion(User(dictionary: data))
            return
        }
    }
    
    static func saveUserData(userId: String, email: String, username: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).setData([
            "userId": userId,
            "email": email,
            "username": username,
            "created_at": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
