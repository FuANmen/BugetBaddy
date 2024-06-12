//
//  BreakDownView.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/03/09.
//

import UIKit

protocol SelectTargetMonthDelegate: AnyObject {
    func okButtonTapped(targetMonth: String)
    func cancelButtonTapped()
}

class SelectTargetMonthView: UIView {
    private var dialogView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private var view: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private var label1: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("SelTargetMonth_MS_001", comment: "")
        return label
    }()
    
    private var picker: MonthYearPicker = {
        let picker = MonthYearPicker()
        return picker
    }()
    
    private var okButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("OK", comment: ""), for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var horizonLine: UIView = {
        let line = UIView()
        line.backgroundColor = .systemGray3
        return line
    }()
    
    private var verticalLine: UIView = {
        let line = UIView()
        line.backgroundColor = .systemGray3
        return line
    }()
    
    weak var delegate: SelectTargetMonthDelegate?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDialogView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDialogView()
    }
    
    // MARK: - Setup
    private func setupDialogView() {
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        
        self.addSubview(dialogView)
        dialogView.addSubview(horizonLine)
        dialogView.addSubview(verticalLine)
        dialogView.addSubview(view)
        dialogView.addSubview(okButton)
        dialogView.addSubview(cancelButton)
        
        view.addSubview(label1)
        view.addSubview(picker)
        
        dialogView.translatesAutoresizingMaskIntoConstraints = false
        horizonLine.translatesAutoresizingMaskIntoConstraints = false
        verticalLine.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        okButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        label1.translatesAutoresizingMaskIntoConstraints = false
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        let viewWidth =  UIScreen.main.bounds.size.width * 0.75
        
        NSLayoutConstraint.activate([
            dialogView.widthAnchor.constraint(equalToConstant: viewWidth),
            dialogView.heightAnchor.constraint(equalToConstant: 160),
            dialogView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            dialogView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            horizonLine.heightAnchor.constraint(equalToConstant: 1),
            horizonLine.leadingAnchor.constraint(equalTo: dialogView.leadingAnchor),
            horizonLine.trailingAnchor.constraint(equalTo: dialogView.trailingAnchor),
            horizonLine.bottomAnchor.constraint(equalTo: dialogView.bottomAnchor, constant: -40),
            
            verticalLine.widthAnchor.constraint(equalToConstant: 1),
            verticalLine.topAnchor.constraint(equalTo: horizonLine.bottomAnchor),
            verticalLine.bottomAnchor.constraint(equalTo: dialogView.bottomAnchor),
            verticalLine.centerXAnchor.constraint(equalTo: dialogView.centerXAnchor),
            
            view.topAnchor.constraint(equalTo: dialogView.topAnchor),
            view.leadingAnchor.constraint(equalTo: dialogView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: dialogView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: horizonLine.topAnchor),
            
            okButton.topAnchor.constraint(equalTo: horizonLine.bottomAnchor),
            okButton.leadingAnchor.constraint(equalTo: dialogView.leadingAnchor),
            okButton.trailingAnchor.constraint(equalTo: verticalLine.leadingAnchor),
            okButton.bottomAnchor.constraint(equalTo: dialogView.bottomAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: horizonLine.bottomAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: verticalLine.trailingAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: dialogView.trailingAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: dialogView.bottomAnchor),
            
            // View
            label1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label1.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            
            picker.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: 8),
            picker.centerXAnchor.constraint(equalTo: dialogView.centerXAnchor),
            picker.bottomAnchor.constraint(equalTo: horizonLine.topAnchor, constant: -8)
        ])
    }
    
    func setupInit(targetMonth: String) {
        self.picker.setup(defaultValue: targetMonth)
    }
    
    // MARK: - Button Actions
    @objc private func okButtonTapped() {
        delegate?.okButtonTapped(targetMonth: picker.selectedMonthYear)
    }
    
    @objc private func cancelButtonTapped() {
        delegate?.cancelButtonTapped()
    }
}
