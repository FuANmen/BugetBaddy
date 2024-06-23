//
//  DateCustom.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/09.
//

import Foundation


class DateFuncs {
    func isValidDateFormat(input: String, format: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        if let _ = dateFormatter.date(from: input) {
            return true
        } else {
            return false
        }
    }
    
    func convertStringToDate(_ dateString: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        return dateFormatter.date(from: dateString)
    }
    
    func convertStringFromDate(_ date: Date, format: String) -> String! {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    func calculateMonthDifference(from fromDate: Date, to toDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: fromDate, to: toDate)
        return components.month ?? 0
    }
    
    func areDatesInSameMonth(date1: String, date2: String? = "") -> Bool {
        let calendar = Calendar.current
        let target1 = self.convertStringToDate(date1, format: "yyyy-MM")!
        if date2 == "" {
            let month1 = calendar.component(.month, from: target1)
            let month2 = calendar.component(.month, from: Date())
            
            return month1 == month2 ? true : false
        } else {
            let target2 = self.convertStringToDate(date2!, format: "yyyy-MM")!
            
            let month1 = calendar.component(.month, from: target1)
            let month2 = calendar.component(.month, from: target2)
            
            return month1 == month2 ? true : false
        }
    }
    
    func getShortDayOfWeek(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        let dayOfWeek = dateFormatter.string(from: date)
        return dayOfWeek
    }
    
    static func numberOfDaysInMonth(yearMonth: String) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        
        guard let date = dateFormatter.date(from: yearMonth) else {
            return nil
        }
        
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)
        return range?.count
    }
}
