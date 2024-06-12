//
//  PlusOrMinusSwitch.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/04.
//

import Foundation
import UIKit
class PlusOrMinusSwitch: UISwitch {
    
    private let onLabel: UILabel = {
        let label = UILabel()
        label.text = "+"
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let offLabel: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    override var isOn: Bool {
        didSet {
            updateLabels()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabels()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLabels()
    }
    
    private func setupLabels() {
        addSubview(onLabel)
        addSubview(offLabel)
        
        onLabel.translatesAutoresizingMaskIntoConstraints = false
        offLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            onLabel.topAnchor.constraint(equalTo: topAnchor),
            onLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            onLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            onLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            offLabel.topAnchor.constraint(equalTo: topAnchor),
            offLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            offLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            offLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        updateLabels()
    }
    
    private func updateLabels() {
        // UISwitch の挙動をカスタマイズする場合、ここで必要な処理を追加する
        onLabel.isHidden = !isOn
        offLabel.isHidden = isOn
    }
}
