//
//  Formatter.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/02/27.
//

import Foundation

func formatCurrency(amount: Double) -> String? {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    // 通貨の記号や桁区切り、小数点以下の桁数などを設定することができます
    // 例: 日本円の場合
    formatter.currencyCode = "JPY"
    formatter.maximumFractionDigits = 0 // 小数点以下の桁数を0に設定して整数の金額として表示する
    
    return formatter.string(from: NSNumber(value: amount))
}
