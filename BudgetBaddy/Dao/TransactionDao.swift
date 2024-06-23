
import RealmSwift

class TransactionDao {
    let realm = try! Realm()
    let IS_SAVINGSPLAN = 1
    
    internal func addTransaction(amount: Double, memo: String, date: Date, paymentMethod: String?, location: String?, category: Category) {
        let transaction = Transaction(category: category, amount: amount, memo: memo, date: date, paymentMethod: paymentMethod, location: location)

        try! realm.write {
            realm.add(transaction)
        }
    }
    
    func getTransactions(predicate: NSPredicate) -> [Transaction] {
        var transactions: [Transaction] = []
        let res = realm.objects(Transaction.self).filter(predicate)
        res.forEach{ tran in
            transactions.append(tran)
        }
        return transactions
    }
    
    internal func getTotalTransactions(targetMonth: String, sortedBy: String? = nil, ascending_flg: Bool? = false) -> [Transaction] {
        var resultTransactions: [Transaction] = []
        
        var predicate: NSPredicate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        let formatedDate = dateFormatter.date(from: targetMonth)
        predicate = NSPredicate(format: "date >= %@ AND date < %@", formatedDate! as CVarArg, Calendar.current.date(byAdding: .month, value: 1, to: formatedDate!)! as CVarArg)
        
        let checkedSortedBy = checkPropDetail(str: sortedBy ?? "date")
        if checkedSortedBy.className == "" {
            let sortProperties = [
                SortDescriptor(keyPath: checkedSortedBy.property, ascending: ascending_flg ?? false)
            ]
            let res = realm.objects(Transaction.self).filter(predicate).sorted(by: sortProperties)
            resultTransactions.append(contentsOf: res)
        } else if checkedSortedBy.className == "category" {
            // TODO: カテゴリによるソート取得
        }
        return resultTransactions
    }
    
    internal func getTransactionsForCategory(category: Category, targetMonth: String, sortedBy: String? = nil, ascending_flg: Bool? = nil) -> [Transaction] {
        var resultTransactions: [Transaction] = []
        // フィルター設定
        var predicate: NSPredicate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        let formatedDate = dateFormatter.date(from: targetMonth)
        predicate = NSPredicate(format: "date >= %@ AND date < %@ AND category.name == %@", formatedDate! as CVarArg
                                , Calendar.current.date(byAdding: .month, value: 1, to: formatedDate!)! as CVarArg
                                , category.name)
    
        // Transaction取得
        let transFilterdByCateg = realm.objects(Transaction.self).filter(predicate)
        
        // ソート
        let checkedSortedBy = checkPropDetail(str: sortedBy ?? "date")
        if checkedSortedBy.className == "" {
            let sortProperties = [
                SortDescriptor(keyPath: checkedSortedBy.property, ascending: ascending_flg ?? false)
            ]
            let res = transFilterdByCateg.sorted(by: sortProperties)
            resultTransactions.append(contentsOf: res)
        } else if checkedSortedBy.className == "category" {
            // TODO: カテゴリによるソート
            resultTransactions.append(contentsOf: transFilterdByCateg)
        }
        return resultTransactions
    }
    
    internal func getTransactionsAtDate(category: Category?, date: Date) -> [Transaction] {
        var resultTransactions: [Transaction] = []
        let startOfDay = Calendar.current.startOfDay(for: date)
        // Transaction取得
        let predicate: NSPredicate?
        if category != nil {
            predicate = NSPredicate(format: "date >= %@ AND date < %@ AND category.name == %@", startOfDay as CVarArg
                                    , Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)! as CVarArg
                                    , category!.name)
        } else {
            predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as CVarArg
                                    , Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)! as CVarArg)
        }
        let transFilterdByCateg = realm.objects(Transaction.self).filter(predicate!)
        
        // ソート
        let sortProperties = [
            SortDescriptor(keyPath: "date", ascending: false)
        ]
        let res = transFilterdByCateg.sorted(by: sortProperties)
        resultTransactions.append(contentsOf: res)

        return resultTransactions
    }
    
    internal func updateTransaction(transaction: Transaction, amount: Double, memo: String? = "", date: Date, paymentMethod: String?, location: String?) {
        let bf_amount = transaction.amount
        
        try! realm.write {
            transaction.amount = amount
            transaction.memo = memo!
            transaction.date = date
            transaction.paymentMethod = paymentMethod
            transaction.location = location
        }
    }
    
    internal func deleteTransaction(transaction: Transaction) {
        try! realm.write {
            realm.delete(transaction)
        }
    }
}
