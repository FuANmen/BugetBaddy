//
//  RealmClassCommon.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/02/25.
//

import Foundation

func checkPropDetail(str: String) -> (className: String, property: String) {
    let strs = str.components(separatedBy: ".")
    if strs.count == 1 {
        return ("", strs[0])
    } else if strs.count == 2 {
        return (strs[0], strs[1])
    }
    return ("", "")
}
