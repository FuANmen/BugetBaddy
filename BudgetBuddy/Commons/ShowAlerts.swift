//
//  ShowAlerts.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/08.
//

import Foundation
import UIKit

class ShowAlerts {
    init() {
        
    }
    
    func showErrorAlert(message: String) -> UIAlertController{
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        return alertController
    }
}
