//
//  AmountProcessings.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/09.
//

import Foundation

class AmountProcessings {
    func splitAmount(amount: Double, numberOfParts: Int) -> [Double] {
        guard numberOfParts > 0 else {
            return []
        }
        guard amount > 0 else {
            var res: [Double] = []
            for _ in 0..<numberOfParts {
                res.append(0)
            }
            return res
        }

        var baseAmount = floor(amount / Double(numberOfParts))
        let intPart = self.countDigitsInIntegerPart(value: baseAmount)
        if intPart > 2 {
            let multiplier = NSDecimalNumber(decimal: pow(10.0, intPart - 2)).doubleValue
            baseAmount = floor(baseAmount / multiplier) * multiplier
        }
        
        var result: [Double] = Array(repeating: baseAmount, count: numberOfParts)

        let remainder = amount - baseAmount * Double(numberOfParts)

        result[0] += remainder

        return result
    }
    
    func countDigitsInIntegerPart(value: Double) -> Int {
        let stringValue = String(value)
        
        if let dotIndex = stringValue.firstIndex(of: ".") {
            let integerPart = stringValue[..<dotIndex]
            return integerPart.count
        } else {
            return stringValue.count
        }
    }
}
