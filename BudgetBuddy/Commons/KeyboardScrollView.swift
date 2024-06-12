//
//  KeyboardScrollView.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/01/05.
//

import Foundation
import UIKit

class KeyboardScrollView: UIScrollView {

    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }
}
