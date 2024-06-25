//
//  MonthlyTransactions.swift
//  BudgetBaddy
//
//  Created by 柴田健作 on 2024/06/25.
//

import Foundation
import FirebaseFirestore

class MonthlyTransactionsDao {
    // MonthlyTransactions
    static func addMonthlyTransactionsToFirestore(monthlyTransactions: MonthlyTransactions) {
        let db = Firestore.firestore()
        let documentId = monthlyTransactions.targetMonth
        let monthlyTransactionsRef = db.collection("MonthlyTransactions").document(documentId)
        
        monthlyTransactionsRef.setData(monthlyTransactions.toDictionary()) { error in
            if let error = error {
                print("Error adding MonthlyTransactions: \(error)")
            } else {
                print("MonthlyTransactions added successfully")
            }
        }
    }
    
    static func deleteMonthlyTransactions(targetMonth: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let monthlyTransactionsRef = db.collection("MonthlyTransactions").document(targetMonth)

        monthlyTransactionsRef.delete { error in
            if let error = error {
                print("Error deleting MonthlyTransactions: \(error)")
                completion(error)
            } else {
                print("MonthlyTransactions successfully deleted")
                completion(nil)
            }
        }
    }

    static func fetchMonthlyTransactionsFromFirestore(targetMonth: String, completion: @escaping (MonthlyTransactions?) -> Void) {
        let db = Firestore.firestore()
        let monthlyTransactionsRef = db.collection("MonthlyTransactions").document(targetMonth)

        monthlyTransactionsRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let monthlyTransactions = MonthlyTransactions(dictionary: data!)
                completion(monthlyTransactions)
            } else {
                print("MonthlyTransactions not found")
                completion(nil)
            }
        }
    }
    
    // Transactionsfunc
    static func addTransactionToMonthlyTransactions(targetMonth: String, newTransaction: Transaction) {
        let db = Firestore.firestore()
        let monthlyTransactionsRef = db.collection("MonthlyTransactions").document(targetMonth)

        // 新しいTransactionを辞書に変換
        let newTransactionData = newTransaction.toDictionary()

        // FieldValue.arrayUnionを使用してtransactions配列に新しいTransactionを追加
        monthlyTransactionsRef.updateData([
            "transactions": FieldValue.arrayUnion([newTransactionData])
        ]) { error in
            if let error = error {
                print("Error adding transaction to MonthlyTransactions: \(error)")
            } else {
                print("Transaction added to MonthlyTransactions successfully")
            }
        }
    }
    
    func updateTransactionInMonthlyTransactions(targetMonth: String, updatedTransaction: Transaction) {
        let db = Firestore.firestore()
        let monthlyTransactionsRef = db.collection("MonthlyTransactions").document(targetMonth)

        monthlyTransactionsRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var currentData = document.data()!
                var transactions = currentData["transactions"] as! [[String: Any]]
                
                if let index = transactions.firstIndex(where: { $0["id"] as? String == updatedTransaction.id }) {
                    // 既存のtransactionを更新
                    transactions[index] = updatedTransaction.toDictionary()
                } else {
                    print("Transaction not found")
                    return
                }
                
                // Firestoreドキュメントを更新
                monthlyTransactionsRef.updateData([
                    "transactions": transactions
                ]) { error in
                    if let error = error {
                        print("Error updating transaction in MonthlyTransactions: \(error)")
                    } else {
                        print("Transaction updated in MonthlyTransactions successfully")
                    }
                }
            } else {
                print("MonthlyTransactions document does not exist")
            }
        }
    }

    func removeTransactionFromMonthlyTransactions(targetMonth: String, transactionToRemove: Transaction) {
        let db = Firestore.firestore()
        let monthlyTransactionsRef = db.collection("MonthlyTransactions").document(targetMonth)

        // 削除対象のTransactionを辞書に変換
        let transactionDataToRemove = transactionToRemove.toDictionary()

        // FieldValue.arrayRemoveを使用してtransactions配列からTransactionを削除
        monthlyTransactionsRef.updateData([
            "transactions": FieldValue.arrayRemove([transactionDataToRemove])
        ]) { error in
            if let error = error {
                print("Error removing transaction from MonthlyTransactions: \(error)")
            } else {
                print("Transaction removed from MonthlyTransactions successfully")
            }
        }
    }
}
