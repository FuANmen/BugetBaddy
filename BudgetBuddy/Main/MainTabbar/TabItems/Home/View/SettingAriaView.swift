//
//  SettingView.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/05/31.
//

import UIKit

class settingAriaView: UIView {
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .clear
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func configure() {
        
    }
    
    internal func getViewHeight() -> CGFloat {
        return 100
    }
    
    private func setupUI() {
        
    }
}
